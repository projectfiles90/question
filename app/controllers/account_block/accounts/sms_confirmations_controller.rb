# frozen_string_literal: true

module AccountBlock
  module Accounts
    class SmsConfirmationsController < ApplicationController
      include BuilderJsonWebToken::JsonWebTokenValidation

      before_action :validate_json_web_token

      def create
        begin
          @sms_otp = SmsOtp.find(@token.id)
        rescue ActiveRecord::RecordNotFound => e
          return render json: { errors: [
            { phone: 'please enter correct OTP' }
          ] }, status: :unprocessable_entity
        end

        # if @sms_otp.valid_until < Time.current
        #   @sms_otp.destroy
        #   return render json: {errors: [
        #     {pin: 'This Pin has expired, please request a new pin code.'},
        #   ]}, status: :unauthorized
        # end
        #@account = AccountBlock::Account.find_by(full_phone_number: @sms_otp.full_phone_number) || AccountBlock::SmsAccount.find_by(full_phone_number: @sms_otp.full_phone_number)
        @account = AccountBlock::Account.find_by("full_phone_number = ? or phone_number = ?", @sms_otp.full_phone_number, @sms_otp.full_phone_number) || AccountBlock::SmsAccount.find_by(full_phone_number: @sms_otp.full_phone_number)
        return render json: {errors: [{account: 'Account not Found',}],}, status: :unprocessable_entity unless @account.present?
        if @sms_otp.activated?
          return render json: ValidateAvailableSerializer.new(@sms_otp, meta: { role: @account.user_type,
                                                                                message: 'Phone Number Already Activated' }).serializable_hash, status: :ok
        end

        if @sms_otp.pin.to_i == params[:pin].to_i
          @sms_otp.activated = true
          # @account.update!(phone_verified: true)
          @account.phone_verified = true
          @account.save(:validate => false)
          @sms_otp.save(validate: false)
          @account.update!(activated: true)
          render json: ValidateAvailableSerializer.new(@sms_otp, meta: {
                                                         role: @account&.user_type,
                                                         message: 'Phone Number Verified and Confirmed Successfully',
                                                         # token: BuilderJsonWebToken.encode(@sms_otp.id),
                                                         token: BuilderJsonWebToken.encode(@account.id),
                                                         id: @account&.id
                                                       }).serializable_hash, status: :ok

        else
          render json: { errors: [
            { pin: 'Invalid OTP for Phone Number' }
          ] }, status: :unprocessable_entity
        end
      end
    end
  end
end
