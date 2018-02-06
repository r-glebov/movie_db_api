class MovieDbService
  include FlowHelper

  GENRES_LIST = {
    '28' => 'action',
    '35' => 'comedy',
    '18' => 'drama',
    '14' => 'fantasy',
    '27' => 'horror'
  }.freeze

  LOCAL_DB_GENRE_LIST = {
    'action'  => 3,
    'comedy'  => 2,
    'drama'   => 1,
    'fantasy' => 4,
    'horror'  => 5
  }.freeze

  def initialize(api_key = Tmdb::Api.key(ENV['TMDB_KEY']))
    @user = User.first || User.create(email: 'seed@test.com', password: 'seed', admin: true)
    @tmdb = Tmdb::Genre
    @image_path = config.images.base_url + config.images.poster_sizes[4]
  end

  def call
    preprocessed_movie_collection.each do |movie|
      result = Movies::Creator.call(params: movie)
      if result.success?
        puts "[ADDED]: #{result.instance.title}"
      else
        puts "[ERROR]: #{result.message.messages}"
      end
    end
  end

  private

  attr_reader :user, :tmdb, :image_path

  def preprocessed_movie_collection
    GENRES_LIST.keys.map do |genre|
      tmdb.movies(genre).results.map do |movie|
        {
          title: movie.title,
          description: movie.overview,
          genre_ids: Array.wrap(LOCAL_DB_GENRE_LIST[GENRES_LIST[genre]]),
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
end

MovieDbService.new.call

