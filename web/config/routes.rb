
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

	devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}

	root to: 'welcome#index'

	get '/invite', to: 'welcome#invite'
	get '/feed', to: 'feeds#index'
	get '/train', to: 'feeds#train'
	get '/retrain', to: 'events#retrain'
	get '/service-worker.js', to: redirect('service-worker.js')
	get '/manifest.json', to: redirect('manifest.json')
	get '/privacy', to: 'welcome#privacy'
	get '/terms', to: 'welcome#terms'

	resources :users
	resources :collections, only: [:index]
	resources :categories
	resources :organizers
	resources :places
	resources :artifacts
	resources :events do
		resource :favorite, only: [:create, :destroy]
	end

	get ':type/:resource_id/follow', to: 'follow#follow', :defaults => {:format => 'js'}, as: :follow
	get ':type/:resource_id/unfollow', to: 'follow#unfollow', :defaults => {:format => 'js'}, as: :unfollow

	authenticate :user, lambda { |u| u.admin? } do
  	mount Sidekiq::Web => '/sidekiq'
	end

	get 'job/submit/:who/:message', to: 'job#submit'

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
