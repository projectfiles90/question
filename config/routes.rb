Rails.application.routes.draw do
  resources :questions

  namespace :bx_block_forgot_password do
    post 'forgot_password', to: 'otps#create'
    post 'otp_confirmation', to: 'otp_confirmations#create'
    post 'new_password', to: 'passwords#create'
  end
  namespace :account_block do
    resource :account do
      post '/email_confirm', to: '/account_block/accounts/email_confirmations#email_confirm'
      post :admin_user_creation
      get '/send_otp', to: '/account_block/accounts#send_otp'
    end
    post "/set_password", to: "/account_block/accounts#set_password"
  end
  namespace :bx_block_login do
    resource :login, only: [:create]
    resources :account_exists
  end


end