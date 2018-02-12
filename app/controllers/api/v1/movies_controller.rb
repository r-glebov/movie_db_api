module Api
  module V1
    class MoviesController < ApplicationController
      skip_before_action :authenticate_user, only: %i[index show]

      include FlowHelper

      # def index
      #   movies = repository.find_all(params.fetch(:filters, {}),
      #                                params.fetch(:pagination, {})) { { es_search: true } }
      #   render json: MovieCollectionSerializer.new(movies).serializable_hash
      # end

      def index
        result = repository.find_all(params.fetch(:filters, {}),
                                     params.fetch(:pagination, {})) { { es_search: true } }
        render json: { facets: result[:facets],
                       results: MovieCollectionSerializer.new(result[:documents]).serializable_hash }
      end

      def create
        success? Movies::Creator.call(params: movie_params.merge(additional_data)) do |result|
          render json: serialize(result.instance)
        end
      end

      def show
        render json: serialize(repository.find(params[:id]), include: [:genres])
      end

      def update
        success? Movies::Updater.call(id: params[:id], params: movie_params) do |result|
          render json: serialize(result.instance)
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

      def serialize(object, options = {})
        MovieSerializer.new(object, options).serializable_hash
      end
    end
  end
end
