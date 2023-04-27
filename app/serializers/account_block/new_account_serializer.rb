module AccountBlock
  class NewAccountSerializer < BuilderBase::BaseSerializer
    attributes *[
      :email,
      :full_phone_number,
      :name,
      :phone_number,
      :gender,
      :date_of_birth,
      :password,
      :type,
      :activated,
      :created_at,
      :updated_at,
      :device_id,
      :unique_auth_id,
      :user_type,
      :phone_verified,
      :email_verified,
      :status
    ]

    attribute :status do |object, params=nil|
      account = params[:current_user]
      group_id = params[:group_id]
      if group_id.present?
	      if object.id == account&.id
	        "accepted"
	      else
	        BxBlockGroupshopping::GroupInvitation.where(invited_user_id: object&.id, group_shopping_id: group_id).first&.status
	      end
	    end  
    end

    attribute :date_of_birth do |object|
      object.date_of_birth.to_s
    end

    attribute :country_code do |object|
      country_code_for object
    end

    attribute :parsed_phone_number do |object|
      phone_number_for object
    end

    attribute :bank_details do |object|
      object.bank_detail
    end

    attribute :business_details do |object|
      BxBlockSettings::BusinessDetailSerializer.new(object.business_detail) if object.business_detail.present?
    end

    class << self
      private

      def country_code_for(object)
        return nil unless Phonelib.valid?(object.full_phone_number)
        Phonelib.parse(object.full_phone_number).country_code
      end

      def phone_number_for(object)
        return nil unless Phonelib.valid?(object.full_phone_number)
        Phonelib.parse(object.full_phone_number).raw_national
      end
    end
  end
end
