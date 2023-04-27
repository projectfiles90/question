# frozen_string_literal: true

module AccountBlock
  module Accounts
    class EmailConfirmationsController < ApplicationController
      include BuilderJsonWebToken::JsonWebTokenValidation

      before_action :validate_json_web_token

      def email_confirm
        begin
          @email_otp = AccountBlock::EmailOtp.find(@token.id)
        rescue ActiveRecord::RecordNotFound => e
          return render json: { errors: [
            { account: 'please enter correct OTP' }
          ] }, status: :unprocessable_entity
        end

        if @email_otp.valid_until < Time.current
          @email_otp.destroy

          return render json: { errors: [
            { pin: 'This Pin has expired, please request a new pin code.' }
          ] }, status: :unauthorized
        end

        @account = AccountBlock::Account.find_by(email: @email_otp.email)
        if @email_otp.activated?
          return render json: ValidateAvailableSerializer.new(@account, meta: {
                                                                message: 'Account Already Activated'
                                                              }).serializable_hash, status: :ok
        end

        if @email_otp.pin.to_s == params['pin'].to_s
          # email_account = AccountBlock::EmailAccount.find_by(email: @email_otp.email)
          email_account = AccountBlock::Account.find_by(email: @email_otp.email)
          email_account.activated = true
          # @account.update!(email_verified: true)
          @account.email_verified = true
          @account.save(:validate => false)
          email_account.save(validate: false)
          render json: ValidateAvailableSerializer.new(@account, meta: {
                                                         role: @account&.user_type,
                                                         message: 'Account Verified and Activated Successfully',
                                                         token: BuilderJsonWebToken.encode(email_account.id),
                                                          id: @account&.id
                                                       }).serializable_hash, status: :ok

        else
          render json: { errors: [
            { pin: 'Invalid OTP for email' }
          ] }, status: :unprocessable_entity
        end
      end
    end
  end
end
