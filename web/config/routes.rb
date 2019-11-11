require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

	devise_for :users, controllers: {
			omniauth_callbacks: 'users/omniauth_callbacks',
			passwords:          'users/passwords',
			sessions:           'users/sessions'
	}

	root to: 'welcome#index'

	namespace 'api' do
		get 'porto-alegre/eventos/:id/similar', to: 'events#similar', as: :events_similar
		get 'porto-alegre/eventos/today', to: 'events#today', as: :today_and_tomorrow_events
		get 'porto-alegre/eventos/week', to: 'events#week', as: :week_events
		get 'porto-alegre/eventos/category/:category', to: 'events#category', as: :category_events
		post 'collections', to: 'collections#index', as: :collections
	end

	get '/feed', to: 'feeds#index'
	get '/onboarding', to: 'bot#onboarding'

	get '/porto-alegre/eventos', to: 'feeds#city', as: :city_events
	get '/porto-alegre/eventos/:day', to: 'feeds#day', as: :day_events, constraints: {day: /(\d{2})-(\d{2})-(\d{4})/}
	get '/porto-alegre/eventos/hoje', to: 'feeds#today', as: :today_events
	get '/porto-alegre/eventos/semana', to: 'feeds#week', as: :week_events
	get '/porto-alegre/eventos/categoria/:category', to: 'feeds#category', as: :category_events

	patch '/invite', to: 'welcome#invite'
	get '/retrain', to: 'events#retrain'
	get '/service-worker.js', to: redirect('service-worker.js')
	get '/manifest.json', to: redirect('manifest.json')

	get 'dashboard', to: 'dashboard#index'

	get '/privacy', to: 'pages#privacy'
	get '/terms', to: 'pages#terms'
	get '/robots.:format', to: 'pages#robots'

	resources :search, only: [:index], path: 'busca'
	resources :train, only: [:index]

	resources :users
	get '/:user/sugestoes', to: 'feeds#suggestions', as: :suggestions_events
	get '/:user/seguindo', to: 'feeds#follow', as: :follow_events
	get '/:user/novos', to: 'feeds#recent', as: :recent_events

	get '/active-invite', to: 'users#active_invite'


	resources :categories
	resources :organizers, path: 'organizadores'
	resources :places, path: 'porto-alegre/locais'
	resources :artifacts

	resources :events, path: 'porto-alegre/eventos' do
		resource :favorite, only: [:create, :destroy]
	end


	get '/send_request_invite_confirmation/:user_id', to: 'emails#send_request_invite_confirmation', as: :send_request_invite_confirmation
	get '/send_invite_activation_link/:user_id', to: 'emails#send_invite_activation_link', as: :send_invite_activation_link


	get ':type/:resource_id/follow', to: 'follow#follow', as: :follow
	get ':type/:resource_id/unfollow', to: 'follow#unfollow', as: :unfollow

	authenticate :user, lambda { |u| u.admin? } do
		mount Sidekiq::Web => '/sidekiq'
	end

	get 'job/submit/:who/:message', to: 'job#submit'

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
