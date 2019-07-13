module EventDecorators
	module Geographic
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def neighborhood
				geographic['neighborhood']
			end

			def neighborhood=(value)
				geographic['neighborhood'] = value
			end
		end

		module ClassMethods

		end

	end
end
