module BxBlockForgotPassword
  class EmailOtpSerializer < BuilderBase::BaseSerializer
    attributes :email, :activated, :created_at, :pin, :valid_until
  end
end
