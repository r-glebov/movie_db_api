class Rating < ApplicationRecord
  belongs_to :movie
  belongs_to :user

  validates :score, numericality: true, greater_than_or_equal_to: 1, lower_than_or_equal_to: 5
end
