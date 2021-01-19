require 'net/http'
require 'openssl'
require 'uri'
require 'json'

task wip: :environment do

	users = User.all

	users.each do |u|
		u.likes.destroy_all
		u.swipable.deep_merge!({
														 :events => {
															 :last_view_at => nil,
															 :finished_at  => nil,
															 :hidden_at    => nil,
															 :active       => true
														 }
													 })

		u.save!
	end



end
