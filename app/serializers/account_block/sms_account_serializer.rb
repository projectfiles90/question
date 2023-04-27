module AccountBlock
  class SmsAccountSerializer
    include FastJsonapi::ObjectSerializer

    attributes *[
      :name,
      :full_phone_number,
      :country_code,
      :phone_number,
      :activated,
      :password,
      :user_type,
      :reffered_by,
      :referral_code
    ]
  end
end
