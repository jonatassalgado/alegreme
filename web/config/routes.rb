require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

	devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}

	root to: 'welcome#index'

	get '/feed', to: 'feeds#index'
	get '/porto-alegre/eventos/hoje', to: 'feeds#today', as: :today_events

	patch '/invite', to: 'welcome#invite'
	get '/retrain', to: 'events#retrain'
	get '/service-worker.js', to: redirect('service-worker.js')
	get '/manifest.json', to: redirect('manifest.json')
	get '/privacy', to: 'welcome#privacy'
	get '/terms', to: 'welcome#terms'

	resources :search, only: [:index]
	resources :train, only: [:index]
	resources :users
	resources :collections, only: [:index]
	resources :categories
	resources :organizers, path: 'organizadores'
	resources :places, path: 'porto-alegre/locais'
	resources :artifacts

	resources :events, path: 'porto-alegre/eventos' do
		resource :favorite, only: [:create, :destroy]
	end


	get '/send_request_invite_confirmation/:user_id', to: 'emails#send_request_invite_confirmation', as: :send_request_invite_confirmation

	get ':type/:resource_id/follow', to: 'follow#follow', :defaults => {:format => 'js'}, as: :follow
	get ':type/:resource_id/unfollow', to: 'follow#unfollow', :defaults => {:format => 'js'}, as: :unfollow

	authenticate :user, lambda { |u| u.admin? } do
		mount Sidekiq::Web => '/sidekiq'
	end

	get 'job/submit/:who/:message', to: 'job#submit'

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
