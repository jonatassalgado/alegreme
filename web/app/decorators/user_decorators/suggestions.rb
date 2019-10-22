module UserDecorators
	module Suggestions

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def events_suggestions
				suggestions['events']
			end

			def has_events_suggestions?
				suggestions['events'].size > 0
			end
		end

		module ClassMethods
		end


		private
	end
end
