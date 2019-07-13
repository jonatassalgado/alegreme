module UserDecorators
	module Demographic

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def name
				features['demographic']['name'] if features['demographic']
			end

			def name=(value)
				features['demographic']['name'] = name
			end

			def picture
				features['demographic']['picture'] if features['demographic']
			end

			def picture=(value)
				features['demographic']['picture'] = picture
			end

			def demographic=(values)
				raise ArgumentError unless values.is_a? Hash
				features['demographic'].update values
			end

		end

		module ClassMethods
		end


		private
	end
end