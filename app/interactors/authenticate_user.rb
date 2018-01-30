class AuthenticateUser
  include Interactor

  delegate :params, to: :context

  def call
    if password_valid?
      context.token = JwtService.encode(contents)
    else
      context.fail!(message: I18n.t('authenticate_user.invalid_credentials'))
    end
  end

  private

  def user
    @user ||= User.find_by(email: params[:user])
  end

  def password_valid?
    user&.authenticate(params[:password])
  end

  def contents
    {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
  end
end
