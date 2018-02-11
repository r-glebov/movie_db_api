class UserSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  attributes :email, :admin, :token
end
