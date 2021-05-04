class BotController < ApplicationController
	before_action :authorize_user


	def onboarding
		gon.push({
				         :env             => Rails.env,
				         :user_id         => current_user.id,
				         :user_first_name => current_user.first_name
		         })

		@swipable_items = get_swipable_items
	end


	private

	def get_swipable_items
		events = Event.in_categories([], {group_by: 2, not_in: %w(anúncio slam protesto experiência outlier)}).limit(24)

		events.map do |event|
			{
					id:             event.id,
					name:           event.name,
					image_url:      event.image[:feed].url(public: true),
					description:    helpers.strip_tags(event.description).truncate(160),
					dominant_color: "#53456a"
			}
		end

	end

end
