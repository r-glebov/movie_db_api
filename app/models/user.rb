class User < ApplicationRecord
  has_secure_password
  has_many :ratings
  has_many :movies
  attr_accessor :token

  validates :email, presence: true, uniqueness: true
  validates :password, :password_confirmation, presence: true, on: [:create, :update]
  validates :password, confirmation: true, on: [:create, :update]
end
