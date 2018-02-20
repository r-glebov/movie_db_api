module Api
  module V1
    class GenresController < ApplicationController
      skip_before_action :authenticate_user, only: %i[index show]

      include Import['genres_repository']
      include FlowHelper

      def index
        render json: serialize(genres_repository.find_all)
      end

      def create
        success? Genres::Creator.call(params: genre_params) do |result|
          render json: serialize(result.instance)
        end
      end

      def show
        render json: serialize(genres_repository.find(params[:id]))
      end

      def update
        success? Genres::Updater.call(id: params[:id], params: genre_params) do |result|
          render json: serialize(result.instance)
        end
      end

      def destroy
        success? Genres::Destroyer.call(id: params[:id]) do
          204
        end
      end

      private

      def genre_params
        params.require(:genre).permit(:name)
      end

      def serialize(object, options = {})
        GenreSerializer.new(object, options).serializable_hash
      end
    end
  end
end
