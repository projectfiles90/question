module AccountBlock
  class EmailAccountSerializer
    include FastJsonapi::ObjectSerializer

    attributes *[
      :email,
      :full_phone_number,
      :name,
      :phone_number,
      :gender,
      :date_of_birth,
      :password,
      :user_type,
      :reffered_by,
      :referral_code
    ]
  end
end
