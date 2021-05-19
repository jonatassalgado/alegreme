module EventDecorators
	module Personas
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def personas_primary_name
				ml_data['personas']['predictions'][0]['result'][0]['value']['choices'][0]
			end

			def personas_primary_name=(value)
				ml_data['personas']['annotations'][0]['result'][0]['value']['choices'] = [value]
			end

			def personas_secondary_name
				# personas_jsonb['secondary']['name']
			end

			def personas_secondary_name=(value)
				# personas_jsonb['secondary']['name'] = value
			end

			def personas_primary_score
				ml_data['personas']['predictions'][0]['score']
			end

			def personas_primary_score=(value)
				# ml_data['personas']['predictions'][0]['result'][0]['value']['choices'][0] = value
			end

			def personas_secondary_score
				# personas_jsonb['secondary']['score']
			end

			def personas_secondary_score=(value)
				# personas_jsonb['secondary']['score'] = value
			end

			def personas_outlier
				# ml_data['personas']['outlier']
			end

			def personas_outlier=(value)
				# ml_data['personas']['outlier'] = value
			end

		end

		module ClassMethods

		end


		private

		def personas_jsonb
			ml_data['personas']
		end

	end
end
