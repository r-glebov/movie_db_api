Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :movies
      resources :genres
      resources :ratings, only: :update
      resource :auth, only: %i[create]
    end
  end
end
