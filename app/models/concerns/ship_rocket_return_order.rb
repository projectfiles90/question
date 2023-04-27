module ShipRocketReturnOrder
  require "uri"
  require "json"
  require "net/http"

  def auth_login_service
    url = URI("https://apiv2.shiprocket.in/v1/external/auth/login")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
      "email": "gaurav@caelum.in",
      "password": "start@123"
    })
    response = https.request(request)
    response = response.read_body
    JSON(response)['token']
  end

  def create_return_order
    @token ||= auth_login_service
    # url = URI("https://apiv2.shiprocket.in/v1/external/orders/create/return")
    url = URI(ENV['url'])
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{@token}"
    request.body = JSON.dump({
      "order_id": "#{self.order_item.order.id}",
      "order_date": "#{self.order_item.order.created_at}",
      "channel_id": "222523",
      "pickup_customer_name": "#{delivery_address&.name}",
      "pickup_last_name": "",
      "company_name": "#{self.order_item.order.account.company_name}",
      "pickup_address": "#{delivery_address&.address_type}",
      "pickup_address_2": "",
      "pickup_city": "#{delivery_address&.city}",
      "pickup_state": "#{delivery_address&.state}",
      "pickup_country": "#{delivery_address&.country}",
      "pickup_pincode": "#{delivery_address&.zip_code}",
      "pickup_email": "#{delivery_address&.email}",
      "pickup_phone": "#{delivery_address&.phone_number}",
      "pickup_isd_code": "#{self.order_item.order.account.country_code}",
      "shipping_customer_name": "#{self.order_item.catalogue.account&.name}",
      # "shipping_last_name": "",
      "shipping_address": "#{self.order_item.catalogue.account&.delivery_addresses&.find_by(is_default: true)&.address}",
      "shipping_address_2": "",
      "shipping_city": "#{self.order_item.catalogue.account&.delivery_addresses&.find_by(is_default: true)&.city}",
      "shipping_country": "#{self.order_item.catalogue.account&.delivery_addresses&.find_by(is_default: true)&.country}",
      "shipping_pincode": self.order_item.catalogue.account&.delivery_addresses&.find_by(is_default: true)&.zip_code,
      "shipping_state": "#{self.order_item.catalogue.account&.delivery_addresses&.find_by(is_default: true)&.state}",
      "shipping_email": "#{self.order_item.catalogue.account&.email}",
      "shipping_isd_code": "",
      "shipping_phone": self.order_item.catalogue.account.delivery_addresses&.find_by(is_default: true)&.phone_number,
      "order_items": [
        {
          "sku": "#{self.order_item.catalogue.sku}",
          "name": "#{self.order_item.catalogue.name}",
          "units": self.order_item.catalogue.quantity.to_i,
          "selling_price": self.order_item.catalogue.price.to_i,
          "discount": self.order_item.catalogue.discount.to_i,
          "qc_enable": false,
          "hsn": "",
          "brand": "",
          "qc_size": ""
        }
      ],
      "payment_method": "COD",
      "total_discount": "",
      "sub_total": self.order_item.order.sub_total.to_i,
      "length": self.order_item.catalogue.length.to_i,
      "breadth": self.order_item.catalogue.breadth.to_i,
      "height": self.order_item.catalogue.height.to_i,
      "weight": self.order_item.catalogue.weight.to_i
    })
    response = https.request(request)
    response.read_body
  end
end
