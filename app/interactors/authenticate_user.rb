class AuthenticateUser
  include Interactor

  delegate :email, :password, to: :context

  def call
    if password_valid?
      context.token = JwtService.encode(contents)
      context.user = user
    else
      context.fail!(message: I18n.t('authenticate_user.invalid_credentials'))
    end
  end

  private

  def user
    @user ||= User.find_by(email: email)
  end

  def password_valid?
    user&.authenticate(password)
  end

  def contents
    {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
  end
end
