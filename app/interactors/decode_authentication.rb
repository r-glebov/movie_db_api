class DecodeAuthentication
  include Interactor

  delegate :headers, to: :context

  def call
    return unless token_present?
    context.result = user if user
  end

  private

  def user
    @user ||= User.find_by(id: decoded_id)
    @user || context.fail!(type: :token, message: I18n.t('decode_authentication.token_invalid')) && nil
  end

  def token_present?
    token.present? && token_contents.present?
  end

  def token
    if authorization_header.blank?
      context.fail!(type: :token, message: I18n.t('decode_authentication.token_missing'))
    else
      authorization_header.split(' ').last
    end
  end

  def authorization_header
    headers['Authorization']
  end

  def token_contents
    @token_contents ||= begin
      decoded = JwtService.decode(token)
      context.fail!(type: :token, message: I18n.t('decode_authentication.token_expired')) unless decoded
      decoded
    end
  end

  def decoded_id
    token_contents['user_id']
  end
end
