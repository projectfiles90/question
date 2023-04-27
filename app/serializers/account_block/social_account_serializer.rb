module AccountBlock
  class SocialAccountSerializer
    include FastJsonapi::ObjectSerializer

    attributes *[
      :name,
      :full_phone_number,
      :country_code,
      :phone_number,
      :email,
      :activated,
      :user_type,
      :reffered_by,
      :referral_code
    ]
  end
end
