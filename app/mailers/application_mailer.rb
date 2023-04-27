class ApplicationMailer < ActionMailer::Base
  default from: 'updates@caelum.in'
  layout 'mailer'

  def attachment_assets
    attachments.inline['caelum_logo.png'] = File.read('app/assets/images/caelum_logo.png')
  end
end
