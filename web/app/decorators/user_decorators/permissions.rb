module UserDecorators
	module Permissions

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def has_permission_to_login?
				beta_requested? && beta_activated?
			end
		end

		module ClassMethods
		end


		private
	end
end