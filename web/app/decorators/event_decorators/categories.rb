module EventDecorators
	module Categories
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def categories_primary_name
				ml_data['categories']['primary']['name']
			end

			def categories_primary_name=(value)
				ml_data['categories']['primary']['name'] = value
			end

			def categories_secondary_name
				ml_data['categories']['secondary']['name']
			end

			def categories_secondary_name=(value)
				ml_data['categories']['secondary']['name'] = value
			end

			def categories_primary_score
				ml_data['categories']['primary']['score']
			end

			def categories_primary_score=(value)
				ml_data['categories']['primary']['score'] = value
			end

			def categories_secondary_score
				ml_data['categories']['secondary']['score']
			end

			def categories_secondary_score=(value)
				ml_data['categories']['secondary']['score'] = value
			end

			def categories_as_model
				event_categories = categories.values_at('primary', 'secondary').map { |category| category['name'] }
				Category.where("(details ->> 'name') IN (:categories)", categories: event_categories)
			end

			def categories_outlier
				ml_data['categories']['outlier']
			end

			def categories_outlier=(value)
				ml_data['categories']['outlier'] = value
			end
		end

		module ClassMethods

		end

	end
end
