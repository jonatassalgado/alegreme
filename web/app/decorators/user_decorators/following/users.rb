module UserDecorators
	module Following
		module Users


			def self.included base
				base.send :include, InstanceMethods
				base.extend ClassMethods
			end

			module InstanceMethods

				def follow_user(user_id)
					user = User.find user_id.to_i

					ActiveRecord::Base.transaction do
						user.followers['users'] << id
						user.followers['total_user'] += 1

						# validate_taste_existence 'users'
						self.follows['users'] << user_id.to_i
						self.follows['users']['total_follows'] += 1
						self.follows['users']['updated_at']     = DateTime.now

						user.save && self.save
					end

					# UpdateUserEventsSuggestionsJob.perform_later(self.id)
				rescue ActiveRecord::RecordInvalid
					puts 'Não foi possível salvar sua ação (ERRO 7813)!'
				end

				def unfollow_user(user_id)
          user = User.find user_id.to_i

					ActiveRecord::Base.transaction do
						user.followers['users'].delete id
						user.followers['total_user'] -= 1

						# validate_taste_existence 'users'
						self.follows['users'].delete user_id.to_i
						self.follows['users']['total_follows'] -= 1
						self.follows['users']['updated_at']     = DateTime.now

						user.save && self.save
					end

					# UpdateUserEventsSuggestionsJob.perform_later(self.id)

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
