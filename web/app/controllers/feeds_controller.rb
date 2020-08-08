include Pagy::Backend

class FeedsController < ApplicationController
	before_action :authorize_user, except: [:index, :today, :category, :week, :city, :day, :neighborhood]
	before_action :authorize_current_user, only: %i[suggestions follow news]
	# before_action :completed_swipable, except: [:index, :today, :category, :week, :city, :day]


	def index
		gon.push({
				         :env             => Rails.env,
				         :user_id         => current_user.try(:id),
				         :user_first_name => current_user.try(:first_name)
		         })

		@saved_events                 ||= current_user ? current_user&.saved_events&.not_ml_data&.active&.order_by_date : Event.none
		@recent_events                ||= Event.not_ml_data.active.not_in_saved(current_user).not_in_disliked(current_user).where("created_at > ?", DateTime.now - 24.hours).includes(:place)
		@events_this_week             ||= Event.not_ml_data.active.not_in_saved(current_user).not_in_disliked(current_user).in_categories(Event::CATEGORIES, {not_in: %w(anúncio slam curso protesto outlier)}).with_high_score.in_days((DateTime.now.beginning_of_day...(DateTime.now.beginning_of_day + 8))).includes(:place).order_by_date
		@events_in_user_suggestions   ||= current_user ? Event.not_ml_data.active.not_in_saved(current_user).not_in_disliked(current_user).not_in(@events_this_week.pluck(:id)).in_user_suggestions(current_user).includes(:place).order_by_date : Event.none
		@events_from_following_topics ||= current_user ? current_user&.events_from_following_topics&.not_ml_data&.active&.not_in_saved(current_user)&.not_in_disliked(current_user)&.includes(:place)&.order_by_date : Event.none
		@events_from_followed_users   ||= current_user ? Event.not_ml_data.active.not_in_disliked(current_user).from_followed_users(current_user).includes(:place).order_by_date : Event.none
		@events_in_my_neighborhood    ||= current_user ? Event.not_ml_data.active.not_in_saved(current_user).not_in_disliked(current_user).with_high_score.in_neighborhoods(["Cidade Baixa"]).includes(:place).order_by_date : Event.none
		@following_users              ||= User.following_users(current_user)
		@swipable_items               = get_swipable_items

	end

	def suggestions
		@events ||= Event.not_ml_data.active.in_user_suggestions(current_user).order_by_date
	end

	def follow
		@events ||= current_user.try(:events_from_following_topics)&.not_ml_data&.active.order_by_date
	end

	def today
		@events ||= Event.not_ml_data.active.with_high_score.not_in_saved(current_user).in_days([DateTime.now.beginning_of_day, (DateTime.now + 1).end_of_day])
	end

	def week
		@events ||= Event.not_ml_data.active.with_high_score.not_in_saved(current_user).in_days((DateTime.now.beginning_of_day..(DateTime.now.beginning_of_day + 8))).order_by_date
	end

	def category
		@categories ||= Event::CATEGORIES.dup
		@events     ||= Event.not_ml_data.active.in_days(session[:stimulus][:days]).in_categories([params[:category]]).order_by_date.includes(:place, :categories)
	end

	def neighborhood
		@neighborhoods ||= Event::NEIGHBORHOODS.dup
		@events        ||= Event.not_ml_data.active.in_neighborhoods([params[:neighborhood].titleize]).in_categories(session[:stimulus][:categories]).order_by_date.includes(:place, :categories)
	end

	def city
		@days       = @stimulus_reflex ? session[:stimulus][:days] : (JSON.parse(params[:days]) rescue [])
		@categories = @stimulus_reflex ? session[:stimulus][:categories] : (JSON.parse(params[:categories]) rescue [])

		@all_events      ||= Event.not_ml_data.active.order_by_date.includes(:place, :categories)
		@filtered_events ||= Event.not_ml_data.active.in_days(@days).in_categories(@categories).order_by_date.includes(:place, :categories)
	end

	def day
		@day    ||= Date.parse params[:day]
		@events ||= Event.not_ml_data.active.in_days([@day]).in_categories(session[:stimulus][:categories]).order_by_date.includes(:place, :categories)
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
			events = Event.not_ml_data.with_high_score.not_in_saved(current_user).not_in_disliked(current_user).in_categories(Event::CATEGORIES, {group_by: 2, not_in: %w(anúncio slam protesto experiência outlier)}).order_by_score.limit(12)
			# 	events = Event.not_ml_data.order_by_score.limit(10)

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
