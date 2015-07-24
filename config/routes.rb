Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'status' => '/application#status'
      get 'settings' => '/application#settings'
      resources :notifications, only: [:index] do
        post :create, on: :member
      end
    end
  end

end
