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
					self.following_by_type('Organizer') | self.following_by_type('Place')
				end

				private


			end

			module ClassMethods
			end


			private

		end
	end
end
