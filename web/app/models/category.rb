class Category < ApplicationRecord
	has_and_belongs_to_many :events, touch: true

	def details_name
		details['name']
	end
	
	def details_display_name
		details['display_name']
	end

	def details_url
		details['url']
	end
end
