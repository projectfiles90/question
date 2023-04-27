module BxBlockForgotPassword
  class PasswordsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    before_action :validate_json_web_token
    def create
      create_params = jsonapi_deserialize(params)

      if create_params['new_password'].present?
      # Check new password requirements
        password_validation = AccountBlock::PasswordValidation.new(create_params['new_password'])
        is_valid = password_validation.valid?
        error_message = password_validation.errors.full_messages.first
        unless is_valid
          return render json: {
            errors: [{
              password: error_message,
            }],
          }, status: :unprocessable_entity
        else

        # Update account with new password
        account = AccountBlock::Account.find(@token.account_id)
        if account.update(:password => create_params['new_password'])
          # Delete OTP object as it's not needed anymore
          # @sms_otp.destroy
          serializer = (account.class.to_s+"Serializer").constantize.new(account)
          serialized_account = serializer.serializable_hash
          render json: serialized_account, status: :created
        else
          render json: {
            errors: [{
              profile: 'Password change failed',
            }],
          }, status: :unprocessable_entity
        end  
        end
        end
      end
  end
end
