class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
	devise :omniauthable, omniauth_providers: [:google_oauth2]

	acts_as_follower

	include UserDecorators::Following
	include UserDecorators::Save
	include UserDecorators::Personas
	include UserDecorators::Demographic
	include UserDecorators::Omniauth



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
