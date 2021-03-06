module Api
  module V1
    class AuthsController < ApplicationController
      skip_before_action :authenticate_user

      def create
        result = AuthenticateUser.call(email: params[:email], password: params[:password])
        if result.success?
          result.user.token = result.token
          render json: UserSerializer.new(result.user).serialized_json
        else
          render json: { error: result.message }, status: :unauthorized
        end
      end
    end
  end
end
