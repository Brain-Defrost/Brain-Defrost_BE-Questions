class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_internal_server_error

  private

  def handle_internal_server_error(exception)
    Rails.logger.error "Internal server error: #{exception.message}"
    render json: { error: { message: 'An unexpected error occurred. Please try again later.' } }, status: :internal_server_error
  end

  def handle_service_error(message)
    render json: { error: { message: message } }, status: :internal_server_error
  end
end
