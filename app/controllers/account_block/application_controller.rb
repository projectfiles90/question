module AccountBlock
  class ApplicationController < ::ApplicationController
    # protect_from_forgery with: :exception
     include BuilderJsonWebToken::JsonWebTokenValidation
  end
end
