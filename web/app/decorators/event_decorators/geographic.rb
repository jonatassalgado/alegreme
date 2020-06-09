module EventDecorators
	module Geographic
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods

			def geographic_address
				geographic['address']
			end

			def geographic_address=(value)
				geographic['address'] = value
			end

			def geographic_latlon
				geographic['latlon']
			end

			def geographic_latlon=(value)
				geographic['latlon'] = value
			end

			def geographic_lat
				geographic['latlon'][0]
			end

			def geographic_lon
				geographic['latlon'][1]
			end

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
