module UserDecorators
	module Omniauth

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods


		end

		module ClassMethods

			def from_omniauth(auth, guest_user, params)
				ap auth
				case auth.provider
				when 'google_oauth2'
					googleId = auth.uid
					email    = auth.extra.id_info.email
					name     = auth.extra.id_info.name
					picture  = auth.extra.id_info.picture
				when 'facebook'
					fbId    = auth.uid
					email   = auth.info.email
					name    = auth.info.name
					picture = auth.info.picture
				else
					return false
				end

				user = User.where(email: email).first

				if user
					user
				else
					user = User.new(email:    email,
					                password: Devise.friendly_token[0, 20])

					user.features.deep_merge!({
							                          'demographic' => {
									                          'name'    => name,
									                          'picture' => picture,
									                          'beta'    => {
											                          'requested' => true,
											                          'activated' => true
									                          },
									                          'social'  => {
											                          'fbId'     => fbId,
											                          'googleId' => googleId
									                          },
							                          }
					                          })

					user.save

					user
				end
			end
		end
	end
end
