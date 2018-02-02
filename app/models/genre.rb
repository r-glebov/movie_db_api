class Genre < ApplicationRecord
  has_many :genre_movies, dependent: :destroy
  has_many :movies, through: :genre_movies

  validates :name, presence: true, uniqueness: true
end
