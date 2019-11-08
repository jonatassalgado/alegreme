module UserDecorators
	module Following
		module Events


			Feature = Struct.new(:places, :organizers)

			def self.included base
				base.send :include, InstanceMethods
				base.extend ClassMethods
			end

			module InstanceMethods
				def events_from_following_features(opts = {})
					@opts     = opts
					@features = Feature.new
					@follows  = self.follows.map { |f| {id: f.followable_id, model: f.followable_type} }.group_by { |a| a[:model].pluralize.underscore }

					@follows.keys.each do |key|
						case key
						when 'places'
							@features.places = @follows[key].map { |a| a[:id] }
						when 'organizers'
							@features.organizers = @follows[key].map { |a| a[:id] }
						end
					end

					if @opts[:pluck_name]
						pluck_name
					else
						default_response
					end
				end

				private

				def default_response
					Event.joins(:place, :organizers)
							.where("places.id IN (?) OR organizers.id IN (?)", @features.places, @features.organizers)
				end

				def pluck_name
					default_response
							.pluck("(events.details ->> 'name')")
				end
			end

			module ClassMethods
			end


			private

		end
	end
end
