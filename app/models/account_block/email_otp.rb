module AccountBlock
  class EmailOtp < ApplicationRecord
    # include Wisper::Publisher

    self.table_name = :email_otps

    validate :valid_email
    validates :email, presence: true

    before_create :generate_pin_and_valid_date
    before_save :delete_email_otp

    attr_reader :phone

    def generate_pin_and_valid_date
      self.pin         = rand(1_000..9_999)
      self.valid_until = Time.current + 5.minutes
    end

    private

    def valid_email
      errors.add(:email, 'Invalid email format') unless email =~ URI::MailTo::EMAIL_REGEXP
    end

    def delete_email_otp
      AccountBlock::EmailOtp.where(email: email).delete_all
    end
  end
end
