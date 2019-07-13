module EventDecorators
	module Theme
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def theme_name
				theme['name']
			end

			def theme_name=(value)
				theme['name'] = value
			end

			def theme_score
				theme['score']
			end

			def theme_score=(value)
				theme['score'] = value
			end

			def theme_outlier
				theme['outlier']
			end

			def theme_outlier=(value)
				theme['outlier'] = value
			end
		end

		module ClassMethods

		end

	end
end
