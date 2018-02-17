class User < ApplicationRecord
  has_secure_password
  has_many :ratings
  has_many :movies
  attr_accessor :token

  validates :email, presence: true, uniqueness: true
  validates :password_confirmation, presence: true
end
