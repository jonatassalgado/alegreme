module UserDecorators
	module Demographic

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def name
				features.dig('demographic', 'name')
			end

			def name=(value)
				features['demographic']['name'] = value
			end

			def first_name
				name.try(:split).try(:first)
			end

			def picture(size = :medium)
				if image.try { |img| img[size] }
					image[size].url(public: true)
				elsif features['demographic']['picture'].present?
					features['demographic']['picture']
				else
					animal = ['cat', 'dog', 'lion', 'coala', 'rabbit', 'tiger', 'fox'].sample
					if size == :small
						"media/images/avatars/#{animal}-small"
					else
						"media/images/avatars/#{animal}-medium"
					end
				end
			end

			def picture=(value)
				features['demographic']['picture'] = value
			end

			def demographic=(values)
				raise ArgumentError unless values.is_a? Hash
				features['demographic'].update values
			end

			def beta_activated?
				features.dig('demographic', 'beta', 'activated').to_boolean
			end

			def beta_activated=(value)
				raise ArgumentError unless value.boolean?
				features['demographic']['beta']['activated'] = value
			end

			def beta_requested?
				features.dig('demographic', 'beta', 'requested').to_boolean
			end

			def beta_requested=(value)
				raise ArgumentError unless value.boolean?
				features['demographic']['beta']['requested'] = value
			end

			def social_plataform_id
				return 'gmail' unless features.dig('demographic', 'social', 'googleId').blank?
				return 'facebook' unless features.dig('demographic', 'social', 'fbId').blank?
				'email'
			end

		end

		module ClassMethods
		end


		private
	end
end
