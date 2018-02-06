class MovieSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :user_id, :rating, :image_url
  has_many :genres

  def genres
    object.genres.map { |genre| { id: genre.id, name: genre.name } }
  end
end
