module EventServices
	class EventFetcher


		def initialize(relation, params)
			@params   = params
			@relation = get_event_active_record(relation)
		end

		def call
			sockets             = get_sockets_status @params
			user                = @params[:user]
			personas            = user.try(:personas_name)
			categories_on       = sockets[:in_categories]
			organizers_on       = sockets[:in_organizers]
			places_on           = sockets[:in_places]
			in_kinds_on         = sockets[:in_kinds]
			days_on             = sockets[:in_days]
			user_personas_on    = sockets[:in_user_personas]
			user_suggestions_on = sockets[:in_user_suggestions]
			follow_on           = sockets[:in_follow_features]
			order_personas_on   = sockets[:order_by_persona]
			not_in_saved_on     = sockets[:not_in_saved_on]
			not_in_on           = sockets[:not_in]
			order_by_date       = sockets[:order_by_date]
			days                = @params[:in_days]
			organizers          = @params[:in_organizers]
			places              = @params[:in_places]
			categories          = @params[:in_categories]
			not_in              = @params[:not_in]
			limit               = @params[:limit]
			kinds               = @params[:in_kinds]
			group_by            = @params[:group_by]

			@relation
					.active
					.not_in_saved(
							user,
							'turn_on': not_in_saved_on
					)
					.not_in(
							not_in,
							'turn_on': not_in_on
					)
					.in_days(
							days,
							'turn_on': days_on
					)
					.follow_features_by_user(
							user,
							'turn_on': follow_on
					)
					.in_user_suggestions(
							user,
							'turn_on': user_suggestions_on
					)
					.in_user_personas(
							user,
							'turn_on': user_personas_on
					)
					.in_organizers(
							organizers,
							'turn_on': organizers_on
					)
					.in_places(
							places,
							'turn_on': places_on
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
							:place,
							:organizers,
							:categories
					)

		end

		private

		def get_event_active_record(relation)
			if relation.is_a? Array
				Event.where(id: relation)
			elsif relation.is_a? ActiveRecord::Relation
				relation
			end
		end

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
					in_days:             false,
					in_user_personas:    false,
					in_user_suggestions: false,
					in_kinds:            false,
					in_categories:       false,
					in_organizers:       false,
					in_places:           false,
					in_follow_features:  false,
					order_by_date:       false,
					order_by_persona:    false,
					group_by:            false,
					not_in_saved_on:     true,
					not_in_on:           false
			}

			default_sockets.merge(toggles)
		end

	end

end