Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  root to: 'feeds#index'
  get '/train', to: 'feeds#train'
  get '/retrain', to: 'events#retrain'
  
  resources :users
  resources :calendars
  resources :categories
  resources :organizers
  resources :places
  resources :artifacts
  resources :events do
    resource :favorite, only: [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
