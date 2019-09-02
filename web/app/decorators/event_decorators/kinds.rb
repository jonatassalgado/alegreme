module EventDecorators
	module Kinds
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def kinds
				ml_data['kinds']
			end

			def kinds=(value)
				ml_data['kinds'] = value
			end

			def kinds_name
				if ml_data['kinds']
					ml_data['kinds'].map { |kind| kind['name'] }
				else
					[]
				end
			end

			def kinds_add(value)
				if value.is_a? Array
					ml_data['kinds'] |= value
				else
					ml_data['kinds'] |= [value]
				end
			end



		end

		module ClassMethods

		end

	end
end
