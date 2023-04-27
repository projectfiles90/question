module BxBlockSms
  module Providers
    class Twilio
      class << self
        def send_sms(full_phone_number, text_content)
          client = ::Twilio::REST::Client.new(account_id, auth_token)
          client.messages.create({
                                   from: from,
                                   to: full_phone_number,
                                   body: text_content
                                 })
        end

        def account_id
          Rails.env.development? ? "AC3a1265cb1db410e6160416fcf2c67f3e" : ENV["TWILIO_ACCOUNT_ID"]
        end

        def auth_token
          Rails.env.development? ? "6925f6f20218212ee8526469d41500d2" : ENV["TWILIO_AUTH_TOKEN"]
        end

        def from
          Rails.env.development? ? "+16302503992" : ENV["TWILIO_FROM"]
        end
      end
    end
  end
end
