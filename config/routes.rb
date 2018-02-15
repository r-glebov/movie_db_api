Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :movies do
        get 'facets', on: :collection
      end
      resources :genres
      resources :users
      resources :ratings, only: :update
      resource :auth, only: %i[create]
    end
  end
end
