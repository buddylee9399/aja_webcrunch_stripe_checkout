Rails.application.routes.draw do
  resources :subscriptions
  authenticate :user, lambda { |u| u.admin? } do
    # mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users
  scope controller: :static do
    get :pricing
  end
  root to: 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :purchase do
    resources :checkouts
  end

  resources :subscriptions
  get "success", to: "purchase/checkouts#success"

  # resources :webhooks, only: :create
  # resources :billings, only: :create
end
