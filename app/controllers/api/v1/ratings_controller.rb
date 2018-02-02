module Api
  module V1
    class RatingsController < ApplicationController
      include FlowHelper

      def update
        success? Ratings::Updater.call(id: rating.id, params: rating_params.merge(additional_data)) do |result|
          render json: result.instance
        end
      end

      private

      def rating_params
        params.require(:rating).permit(:score)
      end

      def rating
        @rating ||= begin
          repository.find_by_movie(additional_data) || movie.ratings.create(user_id: current_user.id)
        end
      end

      def repository
        @repository ||= Ratings::Repository.new
      end

      def movie
        @movie ||= Movies::Repository.new.find(params[:id])
      end

      def additional_data
        {
          user_id: current_user.id,
          movie_id: movie.id
        }
      end
    end
  end
end
