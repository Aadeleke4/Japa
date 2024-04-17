Rails.application.routes.draw do
  namespace :admin do
    resources :orders
    resources :products do
      resources :stocks
      resources :contact_pages
    resources :about_pages
    end
      resources :categories
  end
  devise_for :admins
  
  
  devise_for :users, controllers: { registrations: 'registrations' }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

# Add routes for editing and updating user details
resources :users, only: [:edit, :update]
  # Defines the root path route ("/")
  root "home#index"

  get '/products', to: 'products#index'
  get '/contact', to: 'contact_pages#show'
  get '/about', to: 'about_pages#show'
  
  authenticated :admin_user do
    root to: "admin#index", as: :admin_root
  end
  resources :products, only: [:index]
  resources :categories, only: [:show]
  resources :categories, only: [:index]
  resources :products, only: [:show]
  get "admin" => "admin#index"
  get "cart" => "carts#show"
  post "/checkout" => "checkouts#create"
  get "success" => "checkouts#success"
  get "cancel" => "checkouts#cancel"
  post "webhooks" => "webhooks#stripe"


  
end
