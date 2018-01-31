module Api
  module V1
    class GenresController < ApplicationController
      include FlowHelper

      def index
        render json: repository.find_all
      end

      def create
        success? Genres::Creator.call(params: genre_params) do |result|
          render json: result.instance
        end
      end

      def show
        render json: repository.find(params[:id])
      end

      def update
        success? Genres::Updater.call(id: params[:id], params: genre_params) do |result|
          render json: result.instance
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

      def repository
        @repository ||= Genres::Repository.new
      end
    end
  end
end
