module UserDecorators
	module Following
		Feature = Struct.new(:categories, :organizers)

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def events_from_followed_features(opts = {})
				features = Feature.new()

				follows = self.follows.map { |f| {id: f.followable_id, model: f.followable_type} }.group_by { |a| a[:model].pluralize.underscore }

				follows.keys.each do |key|
					case key
					when 'categories'
						features.categories = follows[key].map { |a| a[:id] }
					when 'organizers'
						features.organizers = follows[key].map { |a| a[:id] }
					end
				end
				Event.where(categories: {id: features.categories})
						.or(Event.where(organizers: {id: features.organizers}))
						.includes(:categories, :organizers)
			end
		end

		module ClassMethods
		end


		private


	end
end
