Rails.application.routes.draw do
  resources :frames, only: [ :create, :show, :destroy ]

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check
end
