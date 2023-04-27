module AccountBlock
  class AccountsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    before_action :validate_json_web_token, only: [:update, :show, :send_otp]
    before_action :get_account, only: [:update, :show]
    
    def create
      byebug
      case params[:data][:type] #### rescue invalid API format
      when 'sms_account'
        # if signup_params['full_phone_number'].present?
        #   account = SmsAccount.find_by(
        #     full_phone_number: signup_params['full_phone_number'],
        #     activated: true
        #   )
        #   unless account
        #          .nil?
        #     return render json: { errors: [{
        #       account: 'Account already activated'
        #     }] }, status: :unprocessable_entity
        #   end
        sms_otp = if signup_params[:full_phone_number] == '919892624274' || signup_params[:full_phone_number] == '91 9944477113' || signup_params[:full_phone_number] == '919810865978'
                    SmsOtp.new(full_phone_number: signup_params[:full_phone_number])
                  else
                    SmsOtp.new(full_phone_number: "91"+signup_params[:full_phone_number], pin: '1234')
                    # sms_otp = SmsOtp.new(full_phone_number: signup_params[:full_phone_number])
                  end
        if sms_otp.save
          @account = SmsAccount.new(signup_params)
          if params[:data][:attributes][:invite_code].present?
            reffered_account = AccountBlock::Account.find_by(referral_code: params[:data][:attributes][:invite_code])
            if reffered_account.present?
              @account.reffered_by = reffered_account.id
            end
          end
          if @account.save
            render json: SmsAccountSerializer.new(@account, meta: { otp: sms_otp.pin,
                                                                    token: encode(sms_otp.id) }).serializable_hash, status: :created

          else
            render json: { errors: @account.errors.try(:full_messages).try(:last) },
                   status: :unprocessable_entity
          end
        else
          render json: { errors: 'Otp not created' },
                 status: :unprocessable_entity
          # end
        end
      when 'email_account'
        query_email = signup_params['email'].downcase
        if signup_params['email'].present?
          account = EmailAccount.find_by(
            email: signup_params['email'],
            # activated: true
          )
          unless account
                 .nil?
            return render json: { errors: [{
              account: 'Account already activated'
            }] }, status: :unprocessable_entity
          end
        end
        validator = EmailValidation.new(signup_params['email'])
        unless validator.valid?
          return render json: { errors: [
            { account: 'Email invalid' }
          ] }, status: :unprocessable_entity
        end
        otp = EmailOtp.new(email: signup_params[:email])
        if otp.save
          @account = EmailAccount.new(signup_params)
          
          if @account.save
            # send_email_for(otp)
            # @account.update(otp: otp.pin)
            render json: EmailAccountSerializer.new(@account, meta: { token: encode(otp.id), email_pin: otp.pin }).serializable_hash,
                   status: :created
          else
            render json: { errors: @account.errors.try(:full_messages).try(:last) },
                   status: :unprocessable_entity
          end
        else
          render json: {
            errors: [otp.errors]
          }, status: :unprocessable_entity
        end

      when 'social_account'
        # @account = SocialAccount.new(signup_params)
        @account = AccountBlock::Account.find_or_initialize_by(:email => signup_params[:email])
        unless @account.id.present?
          @account.password = signup_params[:email]
        end
        @account.name = signup_params[:name] if signup_params[:name].present?
        @account.user_type = signup_params[:user_type] if signup_params[:user_type].present?
        @account.unique_auth_id = signup_params[:unique_auth_id] if signup_params[:unique_auth_id].present?
        @account.activated = true
        @account.type = "SocialAccount"
        if params[:data][:attributes][:invite_code].present?
          reffered_account = AccountBlock::Account.find_by(referral_code: params[:data][:attributes][:invite_code])
          if reffered_account.present?
            @account.reffered_by = reffered_account.id
          end
        end
        @account.save(validate: false)
        if @account.present?
          render json: SocialAccountSerializer.new(@account, meta: {
                                                     token: encode(@account.id), role: @account.user_type, id: @account.id
                                                   }).serializable_hash, status: :created
        else
          render json: { errors: @account.errors.try(:full_messages).try(:last) },
                 status: :unprocessable_entity
        end
      else
        render json: { errors: [
          { account: 'Invalid Account Type' }
        ] }, status: :unprocessable_entity
      end
    end

    def set_password
      if (params[:data][:type] == "sms_account") || (params[:data][:type] == "email_account")
        password_validation = AccountBlock::PasswordValidation.new(params[:data][:password])
        is_valid = password_validation.valid?
        error_message = password_validation.errors.full_messages.first
        unless is_valid
          return render json: {
            errors: [{
              password: error_message,
            }],
          }, status: :unprocessable_entity
        end
        if params[:data][:type] == "sms_account"
          account = AccountBlock::Account.find_by("full_phone_number = ? or phone_number = ?", params[:data][:full_phone_number], params[:data][:full_phone_number])
        else
          account = AccountBlock::Account.find_by(email:  params[:data][:email])
        end
        if account.present?
          if account.update(:password => params[:data][:password])
            render json: AccountSerializer.new(account, meta: { token: encode(account.id) }).serializable_hash,status: 200
          else
            render json: {
              errors: [{
                profile: 'Password change failed',
              }],
            }, status: :unprocessable_entity
          end
        else
          render json: {errors: [{account: 'Account does not exist',}],}, status: :unprocessable_entity
        end
      end
    end

    def update
      if @account.user_type == 'customer'
        if account_update_params["phone_number"].present?
          @account.full_phone_number = "91#{account_update_params["phone_number"]}"
        end
        if @account.update(account_update_params)
          render json: AccountSerializer.new(@account, meta: { token: encode(@account.id) }).serializable_hash,
                 status: 200
        else
          render json: { errors: @account.errors.try(:full_messages).try(:last), account_error: @account.errors.messages },
                 status: :unprocessable_entity
        end

      elsif @account.user_type == 'vendor'
        update_vendor_profile @account
      end
    end

    def show
      render json: AccountSerializer.new(@account, serialization_options).serializable_hash,
               status: 200
    end

    def admin_user_creation
      admin_user = AdminUser.new(email: params[:email], password: 'password')
      if admin_user.save
        render json: admin_user, status: :created
      else
        render json: { errors: [{ admin_user: 'admin_not_exist' }] }, status: :unprocessable_entity
      end
    end

    def send_otp
      if params[:email].present?
        otp  = EmailOtp.new(email: params[:email])
        save_otp(otp)
      elsif params[:phone_number].present?
        otp = SmsOtp.new(full_phone_number: "91#{params[:phone_number]}", pin: '1234')
        save_otp(otp)
      end
    end

    private

    def encode(id)
      p
      BuilderJsonWebToken.encode id
    end

    def account_update_params
      params.permit(:name, :email, :password, :full_phone_number, :user_type,
                                                        :password_confirmation, :gender, :date_of_birth, :activated, :unique_auth_id, :is_verified, :phone_number)
    end

    def signup_params
      params.require(:data).permit(:type)
      params.require(:data).require(:attributes).permit(:name, :email, :password, :full_phone_number, :user_type, :password_confirmation, :gender, :date_of_birth, :activated, :unique_auth_id, :is_verified, :phone_number)
    end

    def bank_detail_params
      params.permit(:account_holder_name, :account_number, :bank_name, :ifsc_code)
    end

    def business_detail_params
      params.permit(:registered_business_name, :gstin, :tan, :pan, :signature, :signature_image)
    end

    def get_account
      @account = AccountBlock::Account.find(@token.id) if @token.present?
    end

    def serialized_email_otp(email_otp, account_id)
      token = token_for(email_otp, account_id)
      AccountBlock::EmailOtpSerializer.new(
        email_otp,
        meta: { token: token }
      ).serializable_hash
    end

    def send_email_for(email_otp)
      BxBlockForgotPassword::EmailOtpMailer
        .with(otp: email_otp)
        .otp_email.deliver_now
    end

    def token_for(otp_record, account_id)
      BuilderJsonWebToken.encode(
        otp_record.id,
        5.minutes.from_now,
        type: otp_record.class,
        account_id: account_id
      )
    end

    def save_otp(otp)
      if otp.save
        send_email_for(otp) if otp.class.name == "AccountBlock::EmailOtp"
        render json: {token: BuilderJsonWebToken.encode(otp.id),
                      pin: otp.pin,
                      message: "OTP Sent"
                      }
      else
        render json: {message: "OTP not Sent please try again"}
      end
    end

    def update_vendor_profile account
      msg = ""
      if bank_detail_params.present?
        unless account.bank_detail.present?
          BxBlockPayments::BankDetail.create(bank_detail_params.merge(account_id: account.id))
          msg =msg+"==Bank Detail Created Successfully=="
        else
          account.bank_detail.update(bank_detail_params)
          msg = msg+"==Bank details Updated Successfully=="
        end
      end

      if business_detail_params.present?
        unless account.business_detail.present?
          BxBlockPayments::BusinessDetail.create(business_detail_params.merge(account_id: account.id))
          msg =msg+"==Business Detail Created Successfully=="
        else
          account.business_detail.update(business_detail_params)
          msg = msg+"==Business details Updated Successfully=="
        end
      end

      if account_update_params["phone_number"].present?
        account.full_phone_number = "91#{account_update_params["phone_number"]}"
      end
       
      if account_update_params.present?
        if account.update(account_update_params)
          msg = msg+"==Account Updated Successfully=="
        else
          return render json: {message: account.errors.try(:full_messages).try(:last), account_error: account.errors.full_messages}
        end
      end

      render json:  AccountSerializer.new(account,meta: { token: encode(account.id), message: msg}).serializable_hash,
             status: 200
    end
  end
end
