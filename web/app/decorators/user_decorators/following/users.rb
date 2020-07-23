module UserDecorators
	module Following
		module Users


			def self.included base
				base.send :include, InstanceMethods
				base.extend ClassMethods
			end

			module InstanceMethods

				def is_following? followable
					self.try { |user| user.public_send("following_#{followable.class.name.parameterize}?", followable) }
				end


				['user', 'organizer', 'place'].each do |entity_name|
					define_method "follow_#{entity_name}" do |entity_obj|
						entity_class           = Object.const_get entity_name.capitalize
						follower               = entity_obj.is_a?(ApplicationRecord) ? entity_obj : entity_class.find(entity_obj.to_i)
						entity_name_pluralized = entity_name.pluralize

						ActiveRecord::Base.transaction do
							self.following = validate_schema(:following)

							unless self.following[entity_name_pluralized].include?(follower.id)
								follower.followers = validate_schema(:followers)

								self.following["#{entity_name_pluralized}_total_follows"] += 1
								follower.followers['users_total_followers']               += 1
								self.following[entity_name_pluralized]                    |= [follower.id]
								follower.followers['users']                               |= [id]
								self.following['users_updated_at']                        = DateTime.now
							end

							follower.save && self.save
						end
					rescue ActiveRecord::RecordInvalid
						puts 'Não foi possível salvar sua ação (ERRO 8124)!'
					end

					define_method "unfollow_#{entity_name}" do |entity_obj|
						entity_class           = Object.const_get entity_name.capitalize
						follower               = entity_obj.is_a?(ApplicationRecord) ? entity_obj : entity_class.find(entity_obj.to_i)
						entity_name_pluralized = entity_name.pluralize

						ActiveRecord::Base.transaction do
							self.following = validate_schema(:following)

							if self.following[entity_name_pluralized].include?(follower.id)
								self.following["#{entity_name_pluralized}_total_follows"] -= 1
								follower.followers['users_total_followers']               -= 1
								self.following[entity_name_pluralized].delete follower.id
								follower.followers['users'].delete id
								self.following['users_updated_at'] = DateTime.now
							end

							follower.save && self.save
						end
					rescue ActiveRecord::RecordInvalid
						puts 'Não foi possível salvar sua ação (ERRO 8124)!'
					end

					define_method "following_#{entity_name}?" do |entity_obj|
						follower_id = entity_obj.is_a?(ApplicationRecord) ? entity_obj.id : entity_obj.to_i

						self.following[entity_name.pluralize].include? follower_id
					end

					define_method "following_#{entity_name.pluralize}" do
						following[entity_name.pluralize] || []
					end
				end


			end


			private

		end

		module ClassMethods
		end


		private

	end
end
