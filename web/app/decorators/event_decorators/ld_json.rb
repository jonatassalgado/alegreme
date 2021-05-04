module EventDecorators
	module LdJson
		LDJsonStruct = Struct.new(:start_date, :end_date, :price, :low_price, :high_price, :availability, :valid_from)

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def ld_json
				LDJsonStruct.new(
						set_start_date,
						set_end_date,
						set_price,
						set_low_price,
						set_high_price,
						set_availability,
						set_valid_from
				)
			end
		end

		module ClassMethods

		end


		private

		def set_start_date
			datetimes.first.to_datetime.iso8601
		end

		def set_end_date
			if datetimes.size == 1
				(datetimes.first.to_datetime + 2.hours).iso8601
			else
				datetimes.last.to_datetime.iso8601
			end
		end

		def set_price
			prices.try(:min)
		end

		def set_low_price
			prices.try(:min)
		end

		def set_high_price
			prices.try(:max)
		end

		def set_availability
			if datetimes.first.to_datetime >= DateTime.now
				'http://schema.org/InStock'
			else
				'http://schema.org/OutOfStock'
			end
		end

		def set_valid_from
			created_at.to_datetime.iso8601
		end

	end
end
