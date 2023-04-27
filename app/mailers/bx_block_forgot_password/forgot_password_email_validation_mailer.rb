module BxBlockForgotPassword
  class ForgotPasswordEmailValidationMailer < ApplicationMailer
    
    def forgot_password_email(email)
      @host = Rails.env.development? ? 'http://localhost:3000' : ENV["HOST_URL"]
       @url = "https://bxblockForgotPassword/passwordscontroller"

      mail(
          to: email,
          subject: 'Reset Password') do |format|
         format.html { render 'bx_block_forgot_password/forgot_password_email' }
      end
    end
  end
end
