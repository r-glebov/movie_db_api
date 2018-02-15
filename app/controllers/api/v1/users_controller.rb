module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_user, only: %i[create]

      include FlowHelper

      def index
        render json: serialize(repository.find_all)
      end

      def create
        success? Users::Creator.call(params: user_params) do |result|
          render json: serialize(result.instance)
        end
      end

      def show
        render json: serialize(repository.find(params[:id]))
      end

      def update
        success? Users::Updater.call(id: params[:id], params: user_params) do |result|
          render json: serialize(result.instance)
        end
      end

      def destroy
        success? Users::Destroyer.call(id: params[:id]) do
          204
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def repository
        @repository ||= Users::Repository.new
      end

      def serialize(object, options = {})
        UserSerializer.new(object, options).serializable_hash
      end
    end
  end
end
