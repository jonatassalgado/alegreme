module EventDecorators
	module Tags
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def tags_all
				things     = ml_data['tags']['things']
				features   = ml_data['tags']['features']
				activities = ml_data['tags']['activities']

				things&.union(features, activities)
			end

			def tags_of_type(type)
				ml_data['tags'][type] || []
			end

			def tags_things
				ml_data['tags']['things'] || []
			end

			def tags_things_add(value)
				if value.is_a? Array
					ml_data['tags']['things'] = value
				elsif value.is_a? String
					ml_data['tags']['things'] |= [value]
				else
					raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
				end
			end

			def tags_features
				ml_data['tags']['features'] || []
			end

			def tags_features_add(value)
				if value.is_a? Array
					ml_data['tags']['features'] = value
				elsif value.is_a? String
					ml_data['tags']['features'] |= [value]
				else
					raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
				end
			end

			def tags_activities
				ml_data['tags']['activities'] || []
			end

			def tags_activities_add(value)
				if value.is_a? Array
					ml_data['tags']['activities'] = value
				elsif value.is_a? String
					ml_data['tags']['activities'] |= [value]
				else
					raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
				end
			end
		end

		module ClassMethods

		end

	end
end
