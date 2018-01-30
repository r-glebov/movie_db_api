class NotAuthorizedException < StandardError; end

module TokenAuthenticable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user

    before_action :authenticate_user

    rescue_from NotAuthorizedException, with: -> { render json: { error: 'Not Authorized' }, status: :unauthorized }
  end

  private

  def authenticate_user
    @current_user = DecodeAuthentication.call(headers: request.headers).result
    raise NotAuthorizedException unless @current_user
  end
end
