class MovieDbService
  include FlowHelper

  GENRES_LIST = {
    28 => 'Action',
    12 => 'Adventure',
    16 => 'Animation',
    35 => 'Comedy',
    80 => 'Crime',
    99 => 'Documentary',
    18 => 'Drama',
    10_751 => 'Family',
    14 => 'Fantasy',
    36 => 'History',
    27 => 'Horror',
    10_402 => 'Music',
    9648 => 'Mystery',
    10_749 => 'Romance',
    878 => 'Science Fiction',
    10_770 => 'TV Movie',
    53 => 'Thriller',
    10_752 => 'War',
    37 => 'Western'
  }.freeze

  def initialize(_api_key = Tmdb::Api.key(Rails.application.secrets.tmdb_api_key))
    @user = User.first || User.create(email: 'seed@test.com', password: 'seed', admin: true)
    @tmdb = Tmdb::Genre
    @image_path = config.images.base_url + config.images.poster_sizes[4]
  end

  def call
    create_genres
    create_movies
  end

  private

  attr_reader :user, :tmdb, :image_path

  def create_genres
    GENRES_LIST.values.each do |genre_name|
      result = Genres::Creator.call(params: { name: genre_name })
      if result.success?
        puts "[GENRE ADDED]: #{result.instance.name}"
      else
        puts "[GENRE ERROR]: #{result.message.messages}"
      end
    end
  end

  def create_movies
    preprocessed_movie_collection.each do |movie|
      result = Movies::Creator.call(params: movie)
      if result.success?
        puts "[MOVIE ADDED]: #{result.instance.title}"
      else
        puts "[MOVIE ERROR]: #{result.message.messages}"
      end
    end
  end

  def preprocessed_movie_collection
    GENRES_LIST.keys.map do |genre_id|
      tmdb.movies(genre_id).results.map do |movie|
        next if movie.poster_path.blank?
        {
          title: movie.title,
          description: movie.overview,
          genre_ids: map_genres(movie.genre_ids),
          user_id: user.id,
          rating: rand(1..5),
          image_url: image_path + movie.poster_path
        }
      end.flatten
    end.inject(&:+)
  end

  def config
    @config ||= Tmdb::Configuration.get
  end

  def map_genres(ids)
    ids.map { |id| Genre.find_by_name(GENRES_LIST[id]).id }
  end
end

MovieDbService.new.call
