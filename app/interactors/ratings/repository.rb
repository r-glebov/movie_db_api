module Ratings
  class Repository < BaseRepository
    model Rating

    def find_by_movie(options)
      Rating.where(user_id: options[:user_id], movie_id: options[:movie_id]).first
    end
  end
end
