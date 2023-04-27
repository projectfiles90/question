module BxBlockForgotPassword
  class OtpConfirmationsController < ApplicationController
    def create
      create_params = jsonapi_deserialize(params)
      if create_params['token'].present? && create_params['otp_code'].present?
        # Try to decode token with OTP information
        begin
          token = BuilderJsonWebToken.decode(create_params['token'])
        rescue JWT::ExpiredSignature
          return render json: {
            errors: [{
              pin: 'OTP has expired, please request a new one.',
            }],
          }, status: :unauthorized
        rescue JWT::DecodeError => e
          return render json: {
            errors: [{
              token: 'Invalid token',
            }],
          }, status: :bad_request
        end

        # Try to get OTP object from token
        # begin
        #   otp =  AccountBlock::SmsOtp.find_by_id(token.id)
        # rescue ActiveRecord::RecordNotFound => e
        #   return render json: {
        #     errors: [{
        #       otp: 'Token invalid',
        #     }],
        #   }, status: :unprocessable_entity
        # end


        # Try to get OTP object from token

        case params[:data][:type] #### rescue invalid API format
        when 'sms_account'
          begin
            otp = AccountBlock::SmsOtp.find_by_id(token.id)
          rescue ActiveRecord::RecordNotFound => e
            return render json: {
              errors: [{
                otp: 'Token invalid',
              }],
            }, status: :unprocessable_entity
          end
        when 'email_account'
           begin
            otp = AccountBlock::EmailOtp.find_by_id(token.id)
          rescue ActiveRecord::RecordNotFound => e
            return render json: {
              errors: [{
                otp: 'Token invalid',
              }],
            }, status: :unprocessable_entity
          end
        else
          return render json: {errors: [
            {account: 'Invalid Account Type'},
          ]}, status: :unprocessable_entity
        end  

        # Check OTP code
     
        if otp.pin == create_params['otp_code'].to_i
          otp.activated = true
          otp.save
          render json: {
            messages: [{
              otp: 'OTP validation success',
              token: create_params['token']
            }],
          }, status: :created
        else
          return render json: {
            errors: [{
              otp: 'Invalid OTP code',
            }],
          }, status: :unprocessable_entity
        end
      else 
        return render json: {
          errors: [{
            otp: 'Token and OTP code are required',
          }],
        }, status: :unprocessable_entity
      end
    end

  end
end
