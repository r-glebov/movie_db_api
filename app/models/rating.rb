class Rating < ApplicationRecord
  belongs_to :movie
  belongs_to :user

  validates_presence_of :movie
  validates_inclusion_of :score, in: 0..5
end
