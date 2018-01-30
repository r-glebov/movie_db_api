module Api
  module V1
    class AuthsController < ApplicationController
      skip_before_action :authenticate_user
      
      def create
        result = AuthenticateUser.call(params: params)

        if result.success?
          render json: { token: result.token }
        else
          render json: { error: result.message }, status: :unauthorized
        end
      end
    end
  end
end
