module UserDecorators
	module Personas

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def personas_name
				personas_jsonb.map { |persona| persona[1]['name'] }.compact
			end

			def personas_primary_name
				personas_jsonb['primary']['name'] if features['psychographic']
			end

			def personas_primary_name=(value)
				personas_jsonb['primary']['name'] = value
			end

			def personas_secondary_name
				personas_jsonb['secondary']['name'] if features['psychographic']
			end

			def personas_secondary_name=(value)
				personas_jsonb['secondary']['name'] = value
			end

			def personas_primary_score
				personas_jsonb['primary']['score'] if features['psychographic']
			end

			def personas_primary_score=(value)
				personas_jsonb['primary']['score'] = value
			end

			def personas_secondary_score
				personas_jsonb['secondary']['score'] if features['psychographic']
			end

			def personas_secondary_score=(value)
				personas_jsonb['secondary']['score'] = value
			end

			def personas_tertiary_name
				personas_jsonb['tertiary']['name'] if features['psychographic']
			end

			def personas_tertiary_name=(value)
				personas_jsonb['tertiary']['name'] = value
			end

			def personas_quartenary_name
				personas_jsonb['quartenary']['name'] if features['psychographic']
			end

			def personas_quartenary_name=(value)
				personas_jsonb['quartenary']['name'] = value
			end

			def personas_tertiary_score
				personas_jsonb['tertiary']['score'] if features['psychographic']
			end

			def personas_tertiary_score=(value)
				personas_jsonb['tertiary']['score'] = value
			end

			def personas_quartenary_score
				personas_jsonb['quartenary']['score'] if features['psychographic']
			end

			def personas_quartenary_score=(value)
				personas_jsonb['quartenary']['score'] = value
			end

			def personas_assortment_finished?
				personas_jsonb['assortment']['finished'] if features['psychographic']
			end

			def personas_assortment_finished=(value)
				personas_jsonb['assortment']['finished'] = value
			end

			private

			def personas_jsonb
				features['psychographic']['personas']
			end

		end

		module ClassMethods
		end


		private
	end
end