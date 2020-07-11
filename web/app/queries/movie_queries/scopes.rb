module MovieQueries
	module Scopes


		extend ActiveSupport::Concern

		included do

			scope 'active', lambda {
				where("created_at > :time AND collections::jsonb ? 'new release'", time: DateTime.now - 30)
			}

			scope 'order_by_date', lambda {
				order("created_at DESC")
			}

		end
	end
end
