require "sidekiq/web"

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount Sidekiq::Web => "/sidekiq"

  resources :boards, only: [ :index, :create, :show ]
  resources :iterations, only: [ :index ] do
    collection do
      get :next
    end
  end
end
