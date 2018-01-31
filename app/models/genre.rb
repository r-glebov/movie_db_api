class Genre < ApplicationRecord
  has_many :movies, through: :genre_movies

  validates :name, presence: true, uniqueness: true
end
