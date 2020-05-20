module UserDecorators
	module Save
		module Events

			TASTE_TYPES = {
				"save" => {
					past: "saved",
					plural: "saves"
				},
				"unsave" => {
					past: "saved",
					plural: "saves"
				},
				"like" => {
					past: "liked",
					plural: "likes"
				},
				"unlike" => {
					past: "liked",
					plural: "likes"
				},
				"view" => {
					past: "viewed",
					plural: "views"
				},
				"dislike" => {
					past: "disliked",
					plural: "dislikes"
				},
				"undislike" => {
					past: "disliked",
					plural: "dislikes"
				}
			}

			def self.included base
				base.send :include, InstanceMethods
				base.extend ClassMethods
			end


			module InstanceMethods

				def saved_events(opts = {})
					if self && !self.taste_events_saved.empty?
						# uniq
						Event.saved_by_user(self).where("(ocurrences -> 'dates' ->> 0)::timestamptz > ? AND (ml_data -> 'categories' -> 'primary' ->> 'name') != 'outlier'", DateTime.now - 8.hours).order_by_date
						# if opts[:as_model]
						# 	Event.where(id: events.pluck(:id))
						# else
						# 	events
						# end
					else
						[]
					end
				end

				def saved_events_ids
					if self && !self.taste_events_saved.empty?
						Event.saved_by_user(self).active.order_by_date.uniq.pluck(:id)
					else
						[]
					end
				end

				["save", "like",	"view", "dislike"].each do |taste_type|
					define_method "taste_events_#{taste_type}" do |event_id|
						begin
							event = Event.find event_id.to_i

							ActiveRecord::Base.transaction do
								event.entries["#{TASTE_TYPES[taste_type][:past]}_by"] << id
								event.entries["total_#{TASTE_TYPES[taste_type][:plural]}"] += 1

								validate_taste_existence 'events'
								taste['events'][TASTE_TYPES[taste_type][:past]] << event_id.to_i
								taste['events']["total_#{TASTE_TYPES[taste_type][:plural]}"] += 1
								taste['events']['updated_at'] = DateTime.now

								event.save && save
							end

							if taste_type == "save"
								UpdateUserEventsSuggestionsJob.perform_later(self.id)
							end
						rescue ActiveRecord::RecordInvalid
							puts 'Não foi possível salvar sua ação (ERRO 7813)!'
						end
					end
				end

				["unsave", "unlike",	"unview", "undislike"].each do |taste_type|
					define_method "taste_events_#{taste_type}" do |event_id|
						begin
							event = Event.find event_id.to_i

							ActiveRecord::Base.transaction do
								event.entries["#{TASTE_TYPES[taste_type][:past]}_by"].delete id
								event.entries["total_#{TASTE_TYPES[taste_type][:plural]}"] -= 1

								validate_taste_existence 'events'
								taste['events'][TASTE_TYPES[taste_type][:past]].delete event_id.to_i
								taste['events']["total_#{TASTE_TYPES[taste_type][:plural]}"] -= 1
								taste['events']['updated_at'] = DateTime.now

								event.save && save
							end

							if taste_type == "unsave"
								UpdateUserEventsSuggestionsJob.perform_later(self.id)
							end
						rescue ActiveRecord::RecordInvalid
							puts 'Não foi possível salvar sua ação (ERRO 7813)!'
						end
					end
				end

				["save", "like",	"view", "dislike"].each do |taste_type|
					define_method "taste_events_#{TASTE_TYPES[taste_type][:past]}?" do |event_id|
						if taste['events']
							taste['events'][TASTE_TYPES[taste_type][:past]].include? event_id.to_i
						else
							false
						end
					end
				end

				["save", "like",	"view", "dislike"].each do |taste_type|
					define_method "taste_events_#{TASTE_TYPES[taste_type][:past]}" do
						taste['events'][TASTE_TYPES[taste_type][:past]]
					end
				end

				private

			end

			module ClassMethods
			end


			private

		end
	end
end
