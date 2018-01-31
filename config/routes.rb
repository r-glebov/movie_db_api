Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :movies
      resource :auth, only: %i[create]
    end
  end
end
