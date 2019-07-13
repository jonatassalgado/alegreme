module UserDecorators
	module Save
		module Events


			def self.included base
				base.send :include, InstanceMethods
				base.extend ClassMethods
			end

			module InstanceMethods
				def saved_events
					if self && !self.taste_events_saved.empty?
						Event.saved_by_user(self).active.order_by_date.uniq
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

				def taste_events_save(event_id)
					event = Event.find event_id.to_i

					ActiveRecord::Base.transaction do
						event.entries['saved_by'] << id
						event.entries['total_saves'] += 1

						validate_taste_existence 'events'
						taste['events']['saved'] << event_id.to_i
						taste['events']['total_saves'] += 1

						event.save && save
					end

					UpdateUserEventsSuggestionsJob.perform_later(self.id)
				rescue ActiveRecord::RecordInvalid
					puts 'Não foi possível salvar sua ação (ERRO 7813)!'
				end

				def taste_events_unsave(event_id)
					event = Event.find event_id.to_i

					ActiveRecord::Base.transaction do
						event.entries['saved_by'].delete id
						event.entries['total_saves'] -= 1

						validate_taste_existence 'events'
						taste['events']['saved'].delete event_id.to_i
						taste['events']['total_saves'] -= 1

						event.save && save
					end

					UpdateUserEventsSuggestionsJob.perform_later(self.id)

				rescue ActiveRecord::RecordInvalid
					puts 'Não foi possível salvar sua ação (ERRO 7814)!'
				end

				def taste_events_saved?(event_id)
					if taste['events']
						taste['events']['saved'].include? event_id.to_i
					else
						false
					end
				end

				def taste_events_saved
					taste['events']['saved']
				end

				private

			end

			module ClassMethods
			end


			private

		end
	end
end
