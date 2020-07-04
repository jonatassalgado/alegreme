module UserDecorators
	module Following

			include UserDecorators::Following::Events
			include UserDecorators::Following::Topics
			include UserDecorators::Following::Users

			def self.included base
				base.send :include, InstanceMethods
			end

			module InstanceMethods
			  def has_following_resources?
				  following_topics.size
			  end
			end
	end
end
