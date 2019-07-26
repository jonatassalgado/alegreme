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
				def following_topics(opts = {only: []})
					raise ArgumentError unless opts[:only].is_a? Symbol

					@opts = opts


					if @opts[:only] == :name
						@response = self.all_following.map { |follow| follow.details['name'] }
					else
						@response = self.all_following
					end

					if @opts[:as] == :list
						if @opts[:size]
							@response.map { |response| content_tag :i, response }[0...@opts[:size]].join(", ")
						else
							@response.map { |response| content_tag :i, response }.join(", ")
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
end