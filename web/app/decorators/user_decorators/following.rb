module UserDecorators
	module Following

			include UserDecorators::Following::Events
			include UserDecorators::Following::Topics

			def self.included base
				base.send :include, InstanceMethods
			end

			module InstanceMethods
			  def has_following_resources?
			    follow_count > 0
			  end
			end
	end
end
