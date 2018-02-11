class GenreSerializer
  include FastJsonapi::ObjectSerializer
  set_type :genre
  attributes :name
end
