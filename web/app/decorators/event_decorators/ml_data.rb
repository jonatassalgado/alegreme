module EventDecorators
	module MLData
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def ml_data_cleanned
				ml_data['cleanned']
			end
		end

		module ClassMethods

		end


		private



	end
end
