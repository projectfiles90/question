module AccountBlock
  class Account < AccountBlock::ApplicationRecord
    self.table_name = :accounts
    # has_many :wishlists,
    #          class_name: 'BxBlockWishlist2::Wishlist', dependent: :destroy

    # has_many :recent_view_products,
    #          class_name: 'BxBlockCatalogue::RecentViewProduct', dependent: :destroy

    # has_many :customer_products,
    #          class_name: 'BxBlockCatalogue::RecentViewProduct', dependent: :destroy

    # has_many :reviews,
    #          class_name: 'BxBlockCatalogue::Review'

    # has_one :cart_item,
    #         class_name: 'BxBlockShoppingCart::CartItem'

    # has_many :catalogues,
    #          class_name: 'BxBlockCatalogue::Catalogue', dependent: :destroy

    # has_many :orders,
    #          class_name: 'BxBlockOrderManagement::Order', dependent: :destroy

    # has_many :packages,
    #          class_name: 'BxBlockPackaging::Package', dependent: :destroy
    # has_many :order_items, 
    #           class_name: 'BxBlockOrderManagement::OrderItem', dependent: :destroy, foreign_key: 'vendor_id'
    # has_many :delivery_addresses,
    #           class_name: 'BxBlockOrderManagement::DeliveryAddress', dependent: :destroy      
    # has_many :size_charts, 
    #           class_name: 'BxBlockCatalogue::SizeChart', dependent: :destroy
    # has_many :measurement_charts, 
    #           class_name: 'BxBlockCatalogue::MeasurementChart', dependent: :destroy
    # has_many :group_shoppings,
    #           class_name: 'BxBlockGroupshopping::GroupShopping', dependent: :destroy
    # has_many :order_transaction, class_name: 'BxBlockOrderManagement::OrderTransaction', dependent: :destroy
    # has_many :transactions, class_name: 'BxBlockOrderManagement::Transaction', dependent: :destroy
    # has_many :coupons, class_name: "BxBlockCoupons::Coupon"
    # has_one :bank_detail, class_name: 'BxBlockPayments::BankDetail'
    # has_one :business_detail, class_name: 'BxBlockPayments::BusinessDetail'
    # has_many :brands, class_name: 'BxBlockCatalogue::Brand', foreign_key: 'vendor_id'
    # has_one :notification_settings, class_name: 'BxBlockNotifications::NotificationSetting', foreign_key: 'account_id'
    # has_and_belongs_to_many :chatrooms, class_name: 'BxBlockGroupchat::Chatroom'

    enum gender: %i[male female]
    enum user_type:  { customer: 0, vendor: 1, affiliate: 2 }
    # enum status: %i[approved cancel]
    validates :full_phone_number, :email, uniqueness: true, :allow_blank => true
    # before_create :generate_refferal_code
    # has_one :loyalty_point, class_name: 'BxBlockOrderManagement::LoyaltyPoint', dependent: :destroy 

    # include Wisper::Publishern

    # has_secure_password
    has_secure_password(validations: false)
    before_update :setting_up_for_verification
    before_create :update_full_phone_number
    before_create :assign_user_type
    # after_create :create_loyalty_points
    # after_create_commit :send_welcome_email


    def assign_user_type
      unless self.user_type.present?
        self.user_type = "customer"
      end
    end

    def setting_up_for_verification
      if phone_number_changed?
        self.phone_verified =  false
        self.full_phone_number = "91#{self.phone_number}"
      end
      self.email_verified = false if email_changed?
    end

    def update_full_phone_number
      if full_phone_number_changed?
        self.phone_number = full_phone_number
        self.full_phone_number = "91#{full_phone_number}"
        # phone = Phonelib.parse(self.full_phone_number)
        # self.phone_number = phone.raw_national
        # country_code = phone.country_code
        # if country_code.present?
        #   self.full_phone_number = phone.sanitized
        # else
        #   self.full_phone_number = "91#{phone.sanitized}"
        # end
      end  
    end

    # def generate_refferal_code
    #   code = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    #   referal_code = (0...9).map { code[rand(code.length)] }.join
    #   self.referral_code = referal_code
    # end

    # def create_loyalty_points
    #   if user_type == 'customer'
    #     create_loyalty_point
    #     # BxBlockOrderManagement::LoyaltyPoint.create(account_id: self.id, actual_points: 0, pending_points: 0)
    #   end
    # end

    # def send_welcome_email
    #   AccountBlock::AccountMailer.welcome_email(self.email).deliver_now if self.email.present?
    # end

    # validates :password, :email, presence: true
    # validates :password,:format => {
    #   :with      => /^(?=.*[A-Z])(?=.*[#!@$&*?<>',\[\]}{=\-)(^%`~+.:;_])(?=.*[0-9])(?=.*[a-z]).{8,}$/,
    #   :multiline => true,
    #   :confirmation => true
    # }

    # def parse_full_phone_number
    #   phone = Phonelib.parse(full_phone_number)
    #   self.full_phone_number = phone.sanitized
    #   self.country_code      = phone.country_code
    #   self.phone_number      = phone.raw_national
    # end

    # def valid_phone_number
    #   errors.add(:full_phone_number, 'Invalid or Unrecognized Phone Number') unless Phonelib.valid?(full_phone_number)
    # end
  end
end
