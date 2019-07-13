module EventDecorators
	module Tags
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def tags_all
				things     = tags['things']
				features   = tags['features']
				activities = tags['activities']

				things&.union(features, activities)
			end

			def tags_of_type(type)
				tags[type] || []
			end

			def tags_things
				tags['things'] || []
			end

			def tags_things_add(value)
				if value.is_a? Array
					tags['things'] = value
				elsif value.is_a? String
					tags['things'] |= [value]
				else
					raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
				end
			end

			def tags_features
				tags['features'] || []
			end

			def tags_features_add(value)
				if value.is_a? Array
					tags['features'] = value
				elsif value.is_a? String
					tags['features'] |= [value]
				else
					raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
				end
			end

			def tags_activities
				tags['activities'] || []
			end

			def tags_activities_add(value)
				if value.is_a? Array
					tags['activities'] = value
				elsif value.is_a? String
					tags['activities'] |= [value]
				else
					raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
				end
			end
		end

		module ClassMethods

		end

	end
end
