module AccountBlock
  class SmsOtp < ApplicationRecord
    self.table_name = :sms_otps
    # include Wisper::Publisher

    before_validation :parse_full_phone_number
    before_create :generate_pin_and_valid_date
    after_create :send_pin_via_sms
    before_save :delete_sms_otp
    # validate :valid_phone_number
    validates :full_phone_number,
     presence: true

      validates :full_phone_number,:format => {
      :with      => /^([0-9]).{11}$/,
      :multiline => true,
      :confirmation => true
    }

    attr_reader :phone

    def generate_pin_and_valid_date
      if self.full_phone_number == '919892624274' || self.full_phone_number == '919944477113' || self.full_phone_number == '919810865978'
        self.pin = rand(1_000..9_999)
        self.valid_until = Time.current + 5.minutes
      end
    end

    def send_pin_via_sms
      if self.full_phone_number == '919892624274' || self.full_phone_number == '919944477113' || self.full_phone_number == '919810865978'
        message = "Your Pin Number is #{pin}"
        txt = BxBlockSms::SendSms.new("+#{full_phone_number}", message)
        txt.call
      end
    end

    private

    def parse_full_phone_number
      @phone = Phonelib.parse(full_phone_number)
      self.full_phone_number = @phone.sanitized
    end

    def valid_phone_number
      errors.add(:full_phone_number, 'Invalid or Unrecognized Phone Number') unless Phonelib.valid?(full_phone_number)
    end

    def delete_sms_otp
      # AccountBlock::SmsAccount.find_or_create_by(full_phone_number: full_phone_number)
      AccountBlock::SmsOtp.where(full_phone_number: full_phone_number).delete_all
    end
  end
end
