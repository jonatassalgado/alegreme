module UserDecorators
	module Following
		module Topics

			include ActionView::Helpers::TagHelper
			include ERB::Util

			def self.included base
				base.send :include, InstanceMethods
				base.extend ClassMethods
			end

			module InstanceMethods
				def following_topics
					Organizer.where(id: self.following_organizers) | Place.where(id: self.following_places)
				end

				private


			end

			module ClassMethods
			end


			private

		end
	end
end
