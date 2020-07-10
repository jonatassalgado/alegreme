include Pagy::Backend

class FeedsController < ApplicationController
	before_action :authorize_user, except: [:index, :today, :category, :week, :city, :day, :neighborhood]
	before_action :authorize_current_user, only: %i[suggestions follow news]
	# before_action :completed_swipable, except: [:index, :today, :category, :week, :city, :day]


	def index
		gon.push({
				         :env                     => Rails.env,
				         :user_id                 => current_user.try(:id),
				         :user_first_name         => current_user.try(:first_name),
				         :user_sign_in_count      => current_user&.sign_in_count,
				         :user_taste_events_saved => current_user&.taste_events_saved&.size
		         })

		@saved_events                 ||= current_user&.saved_events&.active&.order_by_date
		@new_events_today             ||= Event.active.not_in_saved(current_user).where("created_at > ?", DateTime.now - 24.hours).includes(:place)
		@events_this_week             ||= Event.active.with_high_score.not_in_saved(current_user).in_days((DateTime.now.beginning_of_day.yday..(DateTime.now.beginning_of_day.yday + 8))).includes(:place).order_by_date
		@events_in_user_suggestions   ||= current_user ? Event.active.not_in_saved(current_user).not_in(@events_this_week.map(&:id)).in_user_suggestions(current_user).includes(:place).order_by_date : Event.none
		@events_from_following_topics ||= current_user ? current_user&.events_from_following_topics&.active&.includes(:place)&.order_by_date : Event.none
		@events_from_followed_users   ||= current_user ? Event.active.from_followed_users(current_user).includes(:place).order_by_date : Event.none
		@events_in_my_neighborhood    ||= current_user ? Event.active.with_high_score.in_neighborhoods(["Cidade Baixa"]).includes(:place).order_by_date : Event.none
		@following_users              ||= User.following_users(current_user)
		@swipable_items               ||= get_swipable_items

		@collection_suggestions = {
				identifier:       'user-suggestions',
				events:           @events_in_user_suggestions.limit(session[:stimulus][:limit]),
				total_count:      @events_in_user_suggestions.size,
				title:            {
						principal: "Escolhidos a dedo para #{current_user&.first_name || 'você'}",
						tertiary:  (current_user ? "Com base nos eventos salvos" : "Crie uma conta para ver os eventos abaixo")
				},
				show_similar_to:  session[:stimulus][:show_similar_to],
				continue_to:      "/#{current_user&.slug}/sugestoes",
				display_if_empty: true,
				disposition:      :horizontal
		}

		@collection_follow = {
				identifier:       'follow',
				events:           @events_from_following_topics.limit(session[:stimulus][:limit]),
				total_count:      @events_from_following_topics.size,
				title:            {
						principal: "Tópicos que você segue",
						tertiary:  (current_user ? nil : "Crie uma conta para ver os eventos abaixo"),
				},
				continue_to:      "/#{current_user&.slug}/seguindo",
				show_similar_to:  session[:stimulus][:show_similar_to],
				display_if_empty: true,
				disposition:      :horizontal
		}

		@collection_following_users = {
				identifier:       'following-users',
				events:           @events_from_followed_users.limit(session[:stimulus][:limit]),
				total_count:      @events_from_followed_users.size,
				title:            {
						principal: "Pessoas que você segue",
						tertiary:  (current_user ? nil : "Crie uma conta para ver os eventos abaixo"),
				},
				show_similar_to:  session[:stimulus][:show_similar_to],
				display_if_empty: true,
				disposition:      :horizontal
		}

		@collection_week = {
				identifier:       'this-week',
				events:           @events_this_week.limit(session[:stimulus][:limit]),
				total_count:      @events_this_week.size,
				title:            {
						principal: "Acontecendo esta semana",
						tertiary:  (current_user ? "Com base no seu perfil" : "Crie uma conta para ver os eventos abaixo")
				},
				show_similar_to:  session[:stimulus][:show_similar_to],
				continue_to:      '/porto-alegre/eventos/semana',
				disposition:      :horizontal,
				display_if_empty: true,
				if_greater_than:  2
		}

		@collection_neighborhood = {
				identifier:       'my-neighborhood',
				events:           @events_in_my_neighborhood.limit(session[:stimulus][:limit]),
				total_count:      @events_in_my_neighborhood.size,
				title:            {
						principal: "Nos bairros da sua cidade",
						tertiary:  (current_user ? nil : "Crie uma conta para ver os eventos abaixo"),
				},
				show_similar_to:  session[:stimulus][:show_similar_to],
				display_if_empty: true,
				disposition:      :horizontal
		}

	end

	def recent
		@events ||= Event.active.where("created_at > ?", DateTime.now - 24.hours)

		@collection = {
				identifier:       'new-today',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Adicionados recentemente",
						secondary: "Foram adicionados #{@events.size} eventos nas últimas 16 horas que podem te interessar"
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}

	end

	def suggestions
		@events ||= Event.active.in_user_suggestions(current_user).order_by_date

		@collection = {
				identifier:       'user-suggestions',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Indicados para #{current_user.first_name}",
						secondary: "Explore os eventos que indicamos com base no seu gosto pessoal"
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}

	end

	def follow
		@events ||= current_user.try(:events_from_following_topics)&.active.order_by_date

		@collection = {
				identifier:       'follow',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Tópicos que você segue",
						secondary: "Explore os eventos de organizadores, locais e tags que você segue."
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}

	end

	def today
		@events ||= Event.active.with_high_score.not_in_saved(current_user).in_days([DateTime.now.beginning_of_day.yday, (DateTime.now + 1).end_of_day.yday])

		@collection = {
				identifier:       'today-and-tomorrow',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Eventos em Porto Alegre Hoje e Amanhã",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos que ocorrem hoje e amanhã (#{I18n.l(Date.today, format: :long)} - #{I18n.l(Date.tomorrow, format: :long)}) em Porto Alegre - RS"
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}

	end

	def week
		@events ||= Event.active.with_high_score.not_in_saved(current_user).in_days((DateTime.now.beginning_of_day.yday..(DateTime.now.beginning_of_day.yday + 8))).order_by_date

		@collection = {
				identifier:       'this-week',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: current_user ? "Acontecendo esta semana" : "Eventos acontecendo esta semana em Porto Alegre",
						secondary: "Explore os #{@events.size} eventos que ocorrem hoje (#{I18n.l(Date.today, format: :short)}) até #{I18n.l(Date.today + 6, format: :week)} (#{I18n.l(Date.today + 6, format: :short)}) em Porto Alegre - RS"
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}
	end

	def category
		@categories ||= Event::CATEGORIES.dup
		@events     ||= Event.active.in_days(session[:stimulus][:days]).in_categories([params[:category]]).order_by_date.includes(:place, :categories)

		@collection = {
				identifier:       'category',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Eventos na categoria #{params[:category].try(:capitalize)} em Porto Alegre",
						secondary: "Explore os #{@events.size} eventos de #{params[:category]} em Porto Alegre - RS"
				},
				ocurrences:       Event.day_of_week(@events, active_range: true).sort_by_date.compact_range.uniq.values,
				filters:          {
						ocurrences: true
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}

	end

	def neighborhood
		@neighborhoods ||= Event::NEIGHBORHOODS.dup
		@events        ||= Event.active.in_neighborhoods([params[:neighborhood].titleize]).in_categories(session[:stimulus][:categories]).order_by_date.includes(:place, :categories)

		@collection = {
				identifier:       'neighborhood',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Eventos no bairro #{params[:neighborhood].titleize}",
						secondary: "Explore os #{@events.size} eventos do bairro #{params[:neighborhood].titleize} em Porto Alegre - RS"
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}
	end

	def city
		@events ||= Event.active.in_days(session[:stimulus][:days]).in_categories(session[:stimulus][:categories]).order_by_date.includes(:place, :categories)

		@collection = {
				identifier:       'city',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Eventos em Porto Alegre",
						secondary: current_user ? "Explore todos os eventos ordenados por dia sem filtro de perfil" : "Explore todos os eventos que ocorrem em Porto Alegre - RS"
				},
				categories:       @events.map { |event| event.categories_primary_name }.flatten.uniq,
				ocurrences:       Event.day_of_week(@events, active_range: true).sort_by_date.compact_range.uniq.values,
				filters:          {
						categories: false,
						ocurrences: true
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}
	end

	def day
		@day    ||= Date.parse params[:day]
		@events ||= Event.active.in_days([@day.yday]).in_categories(session[:stimulus][:categories]).order_by_date.includes(:place, :categories)

		@collection = {
				identifier:       'day',
				events:           @events.limit(session[:stimulus][:limit]),
				total_count:      @events.size,
				title:            {
						principal: "Eventos em Porto Alegre que ocorren dia #{I18n.l(@day, format: :long)}",
						secondary: "Acontecem #{@events.size} eventos neste dia"
				},
				categories:       @events.map { |event| event.categories_primary_name }.flatten.uniq,
				filters:          {
						categories: false
				},
				infinite_scroll:  true,
				display_if_empty: true,
				show_similar_to:  session[:stimulus][:show_similar_to]
		}
	end


	private

	def get_events_not_trained_yet
		order = params[:desc] ? "(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric DESC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric DESC" : "(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric ASC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric ASC"

		Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
				.order(order)
				.includes(:place)
	end

	def completed_swipable
		if current_user&.need_to_finish_swipable? && !params[:skip_swipable]
			redirect_to onboarding_path
		end
	end

	def get_swipable_items
		Rails.cache.fetch([current_user, 'swipable_items'], expires_in: 1.hour) do
			events = Event.active.with_high_score.not_in_saved(current_user).not_in_disliked(current_user).in_categories([], {group_by: 2, not_in: %w(anúncio slam protesto experiência outlier)}).includes(:place).order_by_score.limit(24)

			events.map do |event|
				{
						id:             event.id,
						name:           event.details_name,
						image_url:      event.image[:feed].url(public: true),
						description:    helpers.strip_tags(event.details_description).truncate(160),
						dominant_color: helpers.get_image_dominant_color(event)
				}
			end
		end
	end


	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
