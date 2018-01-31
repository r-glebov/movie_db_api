class Movie < ApplicationRecord
  has_many :genres, through: :genre_movies
  has_many :ratings
  belongs_to :user

  validates :title, presence: true, uniqueness: true

  def average_rating
    ratings.sum(:score) / ratings.size
  end
end
