class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true

	def validate_schema column
		case column
		when :following
			following.deep_merge({
					                     'places'                   => following['places'] || [],
					                     'organizers'               => following['organizers'] || [],
					                     'categories'               => following['categories'] || [],
					                     'kinds'                    => following['kinds'] || [],
					                     'tags'                     => following['tags'] || [],
					                     'users'                    => following['users'] || [],
					                     'places_total_follows'     => following['places_total_follows'] || 0,
					                     'organizers_total_follows' => following['organizers_total_follows'] || 0,
					                     'categories_total_follows' => following['categories_total_follows'] || 0,
					                     'kinds_total_follows'      => following['kinds_total_follows'] || 0,
					                     'tags_total_follows'       => following['tags_total_follows'] || 0,
					                     'users_total_follows'      => following['users_total_follows'] || 0,
					                     'places_updated_at'        => DateTime.now,
					                     'organizers_updated_at'    => DateTime.now,
					                     'categories_updated_at'    => DateTime.now,
					                     'kinds_updated_at'         => DateTime.now,
					                     'tags_updated_at'          => DateTime.now,
					                     'users_updated_at'         => DateTime.now,
			                     })
		when :followers
			followers.deep_merge({
					                     'users'                 => followers['users'] || [],
					                     'users_total_followers' => followers['users_total_followers'] || 0
			                     })
		end
	end

end
