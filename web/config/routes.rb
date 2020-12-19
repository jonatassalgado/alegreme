require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

	resources :likes
	devise_for :users, controllers: {
		omniauth_callbacks: 'users/omniauth_callbacks',
		passwords:          'users/passwords',
		sessions:           'users/sessions',
		registrations:      'users/registrations'
	}

	root to: 'welcome#index'

	namespace :api do
		get 'porto-alegre/eventos/:id/similar', to: 'events#similar', as: :events_similar
		get 'porto-alegre/eventos/today', to: 'events#today', as: :today_and_tomorrow_events
		get 'porto-alegre/eventos/week', to: 'events#week', as: :week_events
		get 'porto-alegre/eventos/category/:category', to: 'events#category', as: :category_events
		post 'collections', to: 'collections#index', as: :collections
		post 'taste/:resource/:id/:taste', to: 'taste#update', as: :taste
	end

	get '/porto-alegre', to: 'feeds#index', as: :feed
	get '/porto-alegre/eventos', to: 'feeds#index', as: :city_events
	get '/minha-agenda', to: 'users#agenda', as: :my_agenda

	resources :users, path: 'porto-alegre/u'

	get '/porto-alegre/eventos/:day', to: 'feeds#day', as: :day_events, constraints: { day: /(\d{2})-(\d{2})-(\d{4})/ }
	get '/porto-alegre/eventos/hoje', to: 'feeds#today', as: :today_events
	get '/porto-alegre/eventos/semana', to: 'feeds#week', as: :week_events
	get '/porto-alegre/eventos/categoria(/:category)', to: 'feeds#category', as: :category_events
	get '/porto-alegre/:neighborhood/eventos', to: 'feeds#neighborhood', as: :neighborhood_events

	patch '/invite', to: 'welcome#invite'
	get '/retrain', to: 'events#retrain'
	get '/service-worker.js', to: redirect('service-worker.js')
	get '/manifest.json', to: redirect('manifest.json')

	get 'dashboard', to: 'dashboard#index'

	get '/privacy', to: 'pages#privacy'
	get '/terms', to: 'pages#terms'
	get '/robots.:format', to: 'pages#robots'

	get '/:id/sugestoes', to: 'feeds#suggestions', as: :suggestions_events
	get '/:id/seguindo', to: 'feeds#follow', as: :follow_events

	get '/active-invite', to: 'users#active_invite'

	namespace :sheets do
		resource :friendships, only: :edit
	end

	resources :categories
	resources :organizers, path: 'organizadores' do
		member do
			post :follow
			post :unfollow
		end
	end
	resources :places, path: 'porto-alegre/locais' do
		member do
			post :follow
			post :unfollow
		end
	end
	resources :artifacts

	resources :events, path: 'porto-alegre/eventos' do
		member do
			post :like
			post :unlike
		end
		collection do
			get :saves
			get :recent, path: 'novos'
		end
	end
	resources :movies, path: 'porto-alegre/filmes', as: :movies
	resources :cine_films, controller: 'movies', type: 'CineFilm', path: 'porto-alegre/cinemas', as: :cine_films
	resources :streamings, controller: 'movies', type: 'Streaming', path: 'porto-alegre/streamings', as: :streamings

	get '/send_request_invite_confirmation/:user_id', to: 'emails#send_request_invite_confirmation', as: :send_request_invite_confirmation
	get '/send_invite_activation_link/:user_id', to: 'emails#send_invite_activation_link', as: :send_invite_activation_link

	resources :search, only: [:index], path: 'busca'

	get 'train', to: 'train#index', as: :train

	authenticate :user, lambda { |u| u.admin? } do
		mount Sidekiq::Web => '/sidekiq'
		get 'admin/users', to: 'users#admin'
	end

	get 'job/submit/:who/:message', to: 'job#submit'

	mount ActionCable.server => '/cable'
end
