class MovieSerializer
  include FastJsonapi::ObjectSerializer
  set_type :movie
  attributes :title, :description, :user_id, :rating, :image_url
  has_many :genres
end
