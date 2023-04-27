module AccountBlock
  class SmsOtpSerializer < BuilderBase::BaseSerializer
  	attributes :full_phone_number, :activated, :created_at, :pin, :valid_until
  end
end
