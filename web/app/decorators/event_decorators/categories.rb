module EventDecorators
	module Categories
		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def categories_primary_name
				categories&.first&.details&.dig('name')
			end

			def categories_primary_name=(value)
				ml_data['categories']['annotations'][0]['result'][0]['value']['choices'] = [value]
				categories&.first&.details['name'] = value
			end

			def categories_display_name
				categories&.first&.details&.dig('display_name')
			end

			def categories_display_name=(value)
				categories&.first&.details['display_name'] = value
			end

			def categories_url
				categories&.first&.details&.dig('url')
			end

			def categories_url=(value)
				categories&.first&.details['url'] = value
			end

			def categories_secondary_name
				# ml_data['categories']['predictions'][0]['result'][0]['value']['choices'][0]
			end

			def categories_secondary_name=(value)
				# ml_data['categories']['secondary']['name'] = value
			end

			def categories_primary_score
				ml_data['categories']['predictions'][0]['score']
			end

			def categories_primary_score=(value)
				# ml_data['categories']['predictions'][0]['score'] = value
			end

			def categories_secondary_score
				# ml_data['categories']['secondary']['score']
			end

			def categories_secondary_score=(value)
				# ml_data['categories']['secondary']['score'] = value
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
