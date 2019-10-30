class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
	devise :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

	acts_as_follower

	include UserDecorators::Following
	include UserDecorators::Save
	include UserDecorators::Personas
	include UserDecorators::Demographic
	include UserDecorators::Omniauth
	include UserDecorators::Permissions
	include UserDecorators::Requirements
	include UserDecorators::Suggestions
	include UserDecorators::Notifications

	scope 'with_saved_events', lambda {
		where("jsonb_array_length(taste -> 'events' -> 'saved') > 0")
	}

	scope 'with_notifications_actived', lambda {
		where("(notifications -> 'topics' -> 'all' ->> 'active')::boolean")
	}

	def remember_me
    true
  end

	private

	def validate_taste_existence(dictionary = 'events')
		taste[dictionary] ||= {}

		if dictionary == 'events'
			taste[dictionary]['saved']          ||= []
			taste[dictionary]['liked']          ||= []
			taste[dictionary]['viewed']         ||= []
			taste[dictionary]['disliked']       ||= []
			taste[dictionary]['total_saves']    ||= 0
			taste[dictionary]['total_likes']    ||= 0
			taste[dictionary]['total_views']    ||= 0
			taste[dictionary]['total_dislikes'] ||= 0
		end
	end
end
