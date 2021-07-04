module EventDecorators
	module MlData
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def ml_data_stemmed
				ml_data['stemmed']
			end
		end

		module ClassMethods

		end


		private



	end
end
