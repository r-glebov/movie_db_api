module Api
  module V1
    class MoviesController < ApplicationController
      skip_before_action :authenticate_user, only: %i[index show]

      include Import['movies_repository']
      include FlowHelper

      def index
        result = movies_repository.find_all(filters_params, pagination_params) { { es_search: true } }
        render json: { facets: result[:facets],
                       stats: result[:stats],
                       results: MovieCollectionSerializer.new(result[:documents]).serializable_hash }
      end

      def create
        success? Movies::Creator.call(params: movie_params.merge(additional_data)) do |result|
          render json: serialize(result.instance)
        end
      end

      def show
        render json: serialize(movies_repository.find(params[:id]), include: [:genres])
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

      def filters_params
        return {} if params[:filters].blank?
        params.require(:filters).permit(:query, :genre, :rating)
      end

      def pagination_params
        return {} if params[:pagination].blank?
        params.require(:pagination).permit(:page, :per_page)
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
