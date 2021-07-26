module MovieQueries
	module Scopes


		extend ActiveSupport::Concern

		included do

			scope 'active', lambda {
				joins(:screenings).where("screenings.day >= ? AND movies.status = 1", DateTime.now).distinct
			}

			scope 'with_streaming', lambda {
				where("jsonb_array_length(streamings::jsonb) > 0")
			}

			scope 'order_by_date', lambda {
				order("created_at DESC")
			}

			scope 'in_genres', lambda { |categories = []|
				raise ArgumentError unless categories.is_a? Array
				where("? @> ANY (select jsonb_array_elements(details -> 'genres'))", categories.to_json)
			}

		end
	end
end
