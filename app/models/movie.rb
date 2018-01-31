class Movie < ApplicationRecord
  has_many :genres, through: :genre_movies

  validates :title, presence: true
end
