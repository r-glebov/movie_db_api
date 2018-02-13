class Rating < ApplicationRecord
  belongs_to :movie
  belongs_to :user

  after_update { movie.update(rating: movie.average_rating) }

  validates_presence_of :movie
  validates_inclusion_of :score, in: 0..5
end
