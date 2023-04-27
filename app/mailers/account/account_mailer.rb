module AccountBlock
	class AccountMailer < ApplicationMailer
		layout "mailer"
    def welcome_email(email)
      attachment_assets
      # @host = Rails.env.development? ? 'http://localhost:3000' : ENV["HOST_URL"]
       # @url = "#{@host}/account/accounts/email_confirmation?token=#{token}" 
      mail(
        to: email,
        subject: 'Welcome to CAELUM') do |format|
          format.html { render 'account_mailer/welcome_email' }
        end
    end	

	end
end