module AccountBlock
  class SmsAccount < Account
    # include Wisper::Publisher
     validates :full_phone_number, uniqueness: true, presence: true
     validate :mobile_number_uniqness

    def mobile_number_uniqness
      if AccountBlock::SmsAccount.find_by(full_phone_number: "91#{self.full_phone_number}").present?
        errors.add(:full_phone_number, "already exists.")
      end
    end
  end
end
