module BxBlockLogin
  class LoginsController < ApplicationController
    def create
      case params[:data][:type] #### rescue invalid API format
      when 'sms_account', 'email_account', 'social_account'
        account = OpenStruct.new(jsonapi_deserialize(params))
        account.type = params[:data][:type]

        output = AccountAdapter.new

        output.on(:account_not_found) do |_account|
          render json: {
            errors: [{
              failed_login: 'Account not found, or not activated'
            }]
          }, status: :unprocessable_entity
        end

        output.on(:failed_login) do |_account|
          render json: {
            errors: [{
              failed_login: 'Incorrect Password'
            }]
          }, status: :unauthorized
        end

        output.on(:successful_login) do |account, token|
          render json: { meta: { token: token, role: account.user_type, id: account.id} }
        end

        output.login_account(account)
      else
        render json: {
          errors: [{
            account: 'Invalid Account Type'
          }]
        }, status: :unprocessable_entity
      end
    end
  end
end
