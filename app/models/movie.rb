class Movie < ApplicationRecord
  has_many :genre_movies, dependent: :destroy
  has_many :genres, through: :genre_movies
  has_many :ratings, dependent: :destroy
  belongs_to :user

  include Searchable

  validates :title, presence: true, uniqueness: true

  def self.facets_fields
    %w[rating genre]
  end

  def self.filter_fields
    %w[rating genre]
  end

  def repository
    @repository ||= Movies::Repository.new
  end

  def average_rating
    (ratings.sum(:score) / ratings.size).ceil if ratings.present?
  end

  def as_indexed_json(_options = {})
    record.attributes.merge(
      keyword_filters: genre_filters(record),
      integer_filters: {
        filter_name: 'rating',
        filter_value: record.rating
      }
    )
  end

  def genre_filters(movie)
    Array.wrap(Array.wrap(movie.genres).map(&:name)).map do |genre|
      {
        filter_name: 'genre',
        filter_value: genre
      }
    end
  end
end
