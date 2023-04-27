module ShipRocketAddress
  extend ActiveSupport::Concern
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

  def add_pickup_location address
    @token ||= auth_login_service
    url = URI("https://apiv2.shiprocket.in/v1/external/settings/company/addpickup")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{@token}"

    request.body = JSON.dump({
      "pickup_location": "#{address.save_address_as}_#{address.id}",
      "name": "#{address.name}",
      "email": "#{address.email}",
      "phone": "#{address.phone_number}",
      "address": "Flat no. #{address.address}",
      # "address_2": "id_#{address.id}",
      "city": "#{address.city}",
      "state": "#{address.state}",
      "country": "#{address.country}",
      "pin_code": "#{address.zip_code}"
    })
    response = https.request(request)
    response.read_body
  end
end
