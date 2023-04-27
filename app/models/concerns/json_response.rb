class JsonResponse
  attr_reader :success, :message, :data, :meta, :errors

  def initialize(options = {})
    @success = options[:success].to_s.empty? ? true : options[:success]
    @message = options[:message] || ''
    @data = options[:data] || []
    @meta = options[:meta] || []
    @errors = options[:errors] || { detail: [] }
  end

  def as_json(*)
    {
      success: success,
      message: message,
      data: data,
      meta: meta,
      errors: errors
    }
  end
end
