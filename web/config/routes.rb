Rails.application.routes.draw do

	devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}

	authenticated :user do
		root 'feeds#index', as: :authenticated_root
	end

	root to: 'welcome#index'
	get '/invite', to: 'welcome#invite'
	get '/feed', to: 'feeds#index'
	get '/train', to: 'feeds#train'
	get '/retrain', to: 'events#retrain'
	get '/service-worker.js', to: redirect('service-worker.js')
	get '/manifest.json', to: redirect('manifest.json')
	# match "/manifest.json"

	resources :users
	resources :collections, only: [:index]
	resources :calendars
	resources :categories
	resources :organizers
	resources :places
	resources :artifacts
	resources :events do
		resource :favorite, only: [:create, :destroy]
	end
	get ':type/:resource_id/follow', to: 'follow#follow', :defaults => {:format => 'js'}, as: :follow
	get ':type/:resource_id/unfollow', to: 'follow#unfollow', :defaults => {:format => 'js'}, as: :unfollow
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
