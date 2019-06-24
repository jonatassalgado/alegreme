module EventServices
	class EventFetcher


		def initialize(relation, params)
			@params   = params
			@relation = relation
		end

		def call
			sockets           = get_sockets_status @params
			categories_on     = sockets[:in_categories]
			in_kinds_on       = sockets[:in_kinds]
			days_on           = sockets[:in_days]
			user_on           = sockets[:for_user]
			order_personas_on = sockets[:order_by_persona]
			days              = @params[:in_days]
			user              = @params[:for_user]
			personas          = user.try(:personas_name)
			categories        = @params[:in_categories]
			limit             = @params[:limit]
			kinds             = @params[:in_kinds]
			order_by_date     = sockets[:order_by_date]
			group_by          = @params[:group_by]

			@relation
					.in_days(
							days,
							'turn_on': days_on
					)
					.for_user(
							user,
							'turn_on': user_on
					)
					.in_categories(
							categories,
							'personas': personas,
							'group_by': group_by,
							'turn_on':  categories_on
					)
					.in_kinds(
							kinds,
							'turn_on': in_kinds_on
					)
					.order_by_persona(
							order_personas_on,
							personas: personas
					)
					.order_by_date(
							order_by_date
					)
					.limit(
							limit
					)
					.includes(
							:place
					)

		end

		private

		def get_sockets_status(sockets = {})
			toggles    = {}
			order_keys = [:order_by_date, :order_by_persona]

			sockets.keys.map do |key|
				if order_keys.include? key
					toggles[key] = sockets[key]
				else
					toggles[key] = true
				end
			end

			default_sockets = {
					in_days:          false,
					for_user:         false,
					in_kinds:         false,
					in_categories:    false,
					order_by_date:    false,
					order_by_persona: false,
					group_by:         false
			}

			default_sockets.merge(toggles)
		end

	end

end