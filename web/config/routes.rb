Rails.application.routes.draw do
  get 'foo/bar'
  devise_for :users

  root to: 'feeds#index'
  get '/train', to: 'feeds#train'

  resources :users
  resources :calendars
  resources :categories
  resources :organizers
  resources :places
  resources :events do
    resource :favorite, only: [:create, :destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
