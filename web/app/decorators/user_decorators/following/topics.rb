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
				def following_topics(opts = {})

					@opts = opts

					if @opts[:only] == :name
						@response = self.all_following.map { |follow| follow.details['name'].capitalize }.uniq
					else
						@response = self.all_following
					end

					if @opts[:as] == :list
						if @opts[:size]
							return @response.map { |response| content_tag :i, response }[0...@opts[:size]].join(", ")
						else
							return @response.map { |response| content_tag :i, response }.join(", ")
						end
					else
						@response
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
