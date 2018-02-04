class UserSerializer < ActiveModel::Serializer
  type 'user'
  attributes :id, :email, :admin
end
