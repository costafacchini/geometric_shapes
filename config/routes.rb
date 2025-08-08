Rails.application.routes.draw do
  resources :frames, only: [ :create, :show, :destroy ] do
    resources :circles, only: [ :create ], controller: "frames/circles"
  end

  resources :circles, only: [ :update ]

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check
end
