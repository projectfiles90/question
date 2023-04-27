class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  # skip_before_action :verify_authenticity_token
  # protect_from_forgery with: :null_session
  
  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, PATCH, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def serialization_options
    current_user = current_user || @current_user
    if current_user
      { params: { host: request.base_url, current_user: current_user } }
    else
      { params: { host: request.base_url } }
    end
  end

  def merge_recursively(first_hash, second_hash)
    first_hash.merge(second_hash) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
  end

  def pagination_details(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page, # use collection.previous_page when using will_paginate
      total_pages: collection.total_pages,
      current_count: collection.length,
      total_count: collection.total_count # use collection.total_entries when using will_paginate
    } if collection.present?
  end

  def paginate(collection)
    if collection.kind_of?(Array)
      Kaminari.paginate_array(collection)
    else
      collection
    end&.page(params[:page]).per(params[:per_page])
  end

  def current_user
    @current_user ||= AccountBlock::Account.find(@token.id) if @token.present?
  end
end

