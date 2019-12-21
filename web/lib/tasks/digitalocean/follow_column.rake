require 'colorize'
require 'open-uri'
require 'net/http'
require 'down'

require_relative '../../../config/initializers/shrine.rb'
require_relative '../../../app/uploaders/event_image_uploader'


namespace :change do
	desc 'Change follow columns from gem to jsonb'
	task follow_column: :environment do

		@counter  = 0

		User.all.each do |user|
			Follow.where(follower_id: user.id).each do |follow|
				user.public_send("follow_#{follow.followable_type.underscore}", follow.followable_id)
			end

			@counter += 1
			puts "#{@events_create_counter} - #{user.id} - #{user.following}".green
		end
	end
end

