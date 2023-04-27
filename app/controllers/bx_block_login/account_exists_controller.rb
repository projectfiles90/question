module BxBlockLogin
  class AccountExistsController < ApplicationController
     def create
      case params[:data][:type]#### rescue invalid API format
      when 'sms_account'
        # account = AccountBlock::Account.find_by(full_phone_number:  params[:data][:full_phone_number])
        account = AccountBlock::Account.find_by("full_phone_number = ? or phone_number = ?", params[:data][:full_phone_number], params[:data][:full_phone_number])
        if account.present?
          render json: { exist: 1}, status: 200
        else
          render json: { exist: 0}, status: 200
        end
      when 'email_account'
        account = AccountBlock::Account.find_by(email:  params[:data][:email])
        if account.present?
         render json: { exist: 1 }, status: 200
        else
          render json: { exist: 0}, status: 200
        end
      when 'social_account' 
        account = AccountBlock::Account.find_by(email:  params[:data][:email])
          if account.present?
            render json: { exist: 1}, status: 200
        else
           render json: { exist: 0}, status: 200
        end
      else
        return render json: {
          errors: [{
            type: 'type not exist',
          }],
        }, status: :unprocessable_entity
      end  
    end
   
  end  
end  