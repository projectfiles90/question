module AccountBlock
  class EmailAccount < Account
    # include Wisper::Publisher
    validates :email, presence: true
  end
end
