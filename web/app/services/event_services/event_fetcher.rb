module EventServices
	class EventFetcher

		def initialize(relation, opts)
			@opts     = opts
			@relation = get_event_active_record(relation)
		end

		def call
			@user = @opts[:user]

			@relation
					.active
					.with_high_score(
							'turn_on': @opts[:with_high_score]
					)
					.not_in_saved(
							@user,
							'turn_on': @opts[:not_in_saved]
					)
					.not_in(
							@opts[:not_in],
							'turn_on': (true unless @opts[:not_in].blank?)
					)
					.only_in(
							@opts[:only_in],
							'turn_on': (true unless @opts[:only_in].blank?)
					)
					.in_days(
							@opts[:in_days],
							'turn_on': (true unless @opts[:in_days].blank?)
					)
					.following_topics_by_user(
							@user,
							'turn_on': @opts[:in_following_topics]
					)
					.in_user_suggestions(
							@user,
							'turn_on': @opts[:in_user_suggestions]
					)
					.in_user_personas(
							@user,
							'turn_on': @opts[:in_user_personas]
					)
					.in_organizers(
							@opts[:in_organizers],
							'turn_on': (true unless @opts[:in_organizers].blank?)
					)
					.in_places(
							@opts[:in_places],
							'turn_on': (true unless @opts[:in_places].blank?)
					)
					.in_neighborhoods(
						@opts[:in_neighborhoods],
						'turn_on': (true unless @opts[:in_neighborhoods].blank?)
					)
					.in_categories(
							@opts[:in_categories],
							'personas': @user.try(:personas_name),
							'group_by': @opts[:group_by],
							'not_in':   @opts[:not_in_categories],
							'turn_on':  (true unless @opts[:in_categories].blank?)
					)
					.in_kinds(
							@opts[:in_kinds],
							'turn_on': (true unless @opts[:in_kinds].blank?)
					)
					.order_by_persona(
							@opts[:order_by_persona],
							personas: @user.try(:personas_name)
					)
					.order_by_date(
							@opts[:order_by_date]
					)
					.order_by_ids(
							@opts[:order_by_ids]
					)
					.limit(
							@opts[:limit]
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

		def get_sockets_status(params = {})

			# toggles    = {}
			# order_keys = [
			# 	:order_by_date,
			# 	:order_by_persona,
			# 	:with_high_score,
			# 	:in_user_personas]
			#
			# params.keys.map do |param|
			# 	if order_keys.include? param
			# 		toggles[param] = params[param]
			# 	else
			# 		toggles[param] = true
			# 	end
			# end
			#
			default_sockets = {
					in_days:             false,
					in_user_suggestions: false,
					in_kinds:            false,
					in_categories:       false,
					in_neighborhoods:    false,
					in_organizers:       false,
					in_places:           false,
					in_following_topics: false,
					group_by:            false,
					not_in_saved:        true,
					not_in_on:           false,
					only_in_on:          false,
					order_by_date:       false,
					order_by_persona:    false,
					order_by_ids:        false,
					with_high_score:     false,
					in_user_personas:    true
			}
			#
			default_sockets.merge(params)
		end

	end

end
