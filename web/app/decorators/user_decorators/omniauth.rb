module UserDecorators
	module Omniauth

		require 'down'

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods

		end

		#noinspection ALL
		module ClassMethods

			def from_omniauth(auth, guest_user, params)

				case auth.provider
				when 'google_oauth2'
					googleId = auth.uid
					email    = auth.info.email
					name     = auth.info.name
					picture  = auth.info.image
				when 'facebook'
					fbId    = auth.uid
					email   = auth.info.email
					name    = auth.info.name
					picture = auth.info.image
				else
					return false
				end

				user = User.where(email: email).first

				if user
					user
				else
					create_user({
							            email:    email,
							            fbId:     fbId,
							            googleId: googleId,
							            name:     name,
							            picture:  picture
					            })
				end
			end

			private

			def create_user(args = {
					    email:    nil,
					    fbId:     nil,
					    googleId: nil,
					    name:     nil,
					    picture:  nil
			    })

				user = User.new(email:    args[:email],
				                password: Devise.friendly_token[0, 20])

				user.features.deep_merge!({
						                          'demographic' => {
								                          'name'    => args[:name],
								                          'picture' => args[:picture],
								                          'beta'    => {
										                          'requested' => true,
										                          'activated' => true
								                          },
								                          'social'  => {
										                          'fbId'     => args[:fbId],
										                          'googleId' => args[:googleId]
								                          },
						                          }
				                          })

				if args[:picture]
					begin
						user_picture = Down.download(args[:picture])
					rescue Down::Error => e
						puts "#{args[:name]} - Erro no download da imagem (#{args[:picture]}) - #{e}"
					else
						user.image = user_picture
						puts "#{args[:name]} - Download da imagem (#{args[:picture]}) - Sucesso"
					end
				end

				user.save
				user
			end
		end
	end
end
