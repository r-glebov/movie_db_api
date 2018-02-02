module Api
  module V1
    class MoviesController < ApplicationController
      include FlowHelper

      def index
        render json: repository.find_all
      end

      def create
        success? Movies::Creator.call(params: movie_params.merge(additional_data)) do |result|
          render json: result.instance
        end
      end

      def show
        render json: repository.find(params[:id])
      end

      def update
        success? Movies::Updater.call(id: params[:id], params: movie_params) do |result|
          render json: result.instance
        end
      end

      def destroy
        success? Movies::Destroyer.call(id: params[:id]) do
          204
        end
      end

      private

      def movie_params
        params.require(:movie).permit(:title, :description)
      end

      def repository
        @repository ||= Movies::Repository.new
      end

      def additional_data
        {
          user_id: current_user.id
        }.merge(genres)
      end

      def genres
        params[:genre_ids].present? ? { genre_ids: params[:genre_ids] } : {}
      end
    end
  end
end
