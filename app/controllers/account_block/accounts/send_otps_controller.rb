module AccountBlock
  module Accounts
    class SendOtpsController < ApplicationController
      def create
        json_params =  account_params
        if json_params['email'].present?
          # Get account by email
          account = AccountBlock::Account.where("LOWER(email) = ?",json_params['email'].downcase).first
          return render json: {
            errors: [{
                       otp: 'Account not found',
                     }],
          }, status: :not_found if account.nil?
          email_otp = AccountBlock::EmailOtp.new(account_params)
          if email_otp.save
            Rails.logger.info "EMAIL_OTPS: " + email_otp.inspect
            Rails.logger.info "Response: " + serialized_email_otp(email_otp, account.id).inspect
            send_email_for(email_otp)
            render json: serialized_email_otp(email_otp, account.id),
                   status: :created
          else
            render json: {
              errors: [email_otp.errors],
            }, status: :unprocessable_entity
          end

        elsif json_params['full_phone_number'].present?
        #   account = SmsAccount.find_by(
        #     full_phone_number: json_params['full_phone_number'],
        #     activated: true)
        #   return render json: { errors: [{
        #                                    account: 'Account already activated',
        #                                  }] }, status: :unprocessable_entity unless account.nil?
          # sms_otp = SmsOtp.new(account_params)
          account = AccountBlock::Account.find_by("full_phone_number = ? or phone_number = ?", "91"+json_params['full_phone_number'], json_params['full_phone_number'])
          return render json: {errors: [{otp: 'Account not found',}],}, status: :not_found if account.nil?
          sms_otp = SmsOtp.new(full_phone_number: "91"+account_params[:full_phone_number], pin: '1234')
          # sms_otp = SmsOtp.new(account_params.merge(pin:"1234"))
          if sms_otp.save
            render json: SmsOtpSerializer.new(sms_otp, meta: {
              token: BuilderJsonWebToken.encode(sms_otp.id),
            }).serializable_hash, status: :created
          else
            render json: { errors: format_activerecord_errors(sms_otp.errors) },
                   status: :unprocessable_entity
          end
        else
          render json: {
            errors: [{
                       otp: 'Email or phone number required',
                     }],
          }, status: :unprocessable_entity
        end
      end
      private
      def format_activerecord_errors(errors)
        result = []
        errors.each do |attribute, error|
          result << { attribute => error }
        end
        result
      end
      def send_email_for(email_otp)
        BxBlockForgotPassword::EmailOtpMailer
          .with(otp: email_otp)
          .otp_email.deliver_now
      end
      def serialized_email_otp(email_otp, account_id)
        token = token_for(email_otp, account_id)
        AccountBlock::EmailOtpSerializer.new(
          email_otp,
          meta: { token: token }
        ).serializable_hash
      end
      def token_for(otp_record, account_id)
        
        BuilderJsonWebToken.encode(
          otp_record.id,
          5.minutes.from_now,
          type: otp_record.class,
          account_id: account_id
        )
      end
      def account_params
        params.require(:data).permit(:full_phone_number,:email)
      end
    end
  end
end
