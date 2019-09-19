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
				data  = auth.extra.id_info
				user  = User.where(email: data.email).first
				# state = Base64.urlsafe_decode64(params['state'])

				# Rails.logger.debug "PERSONAS STATE: #{state.inspect} "
				# raise Exception, 'JSON de personas com enconding incorreto!' unless ['UTF-8', 'US-ASCII', 'ASCII-8BIT'].include? state.encoding.name

				# @personas ||= begin
				# 	YAML.safe_load(state)
				# rescue Psych::SyntaxError
				# 	{}
				# end

				# Rails.logger.debug "PERSONAS YAML: #{@personas.inspect} "
				# Rails.logger.debug "GOOGLE DATA: #{data.inspect} "

				# if @personas.empty?
				# 	unless user
				# 		user = User.create(email:    data.email,
				# 		                   password: Devise.friendly_token[0, 20])
				# 	end
				#
				# 	user.features.deep_merge!({
				# 			                          'psychographic' => guest_user.features['psychographic'],
				# 			                          'demographic'   => {
				# 					                          'name'    => data.name,
				# 					                          'picture' => data.picture
				# 			                          }
				# 	                          })
				# if @personas && @personas['assortment']['finished']


				if user
					return user
				else
					features = {
						'demographic'   => {
							'name'    => data.name,
							'picture' => data.picture
						}
					}

					user = User.new(email:    data.email,
						password: Devise.friendly_token[0, 20])

						user.features.deep_merge!(features)

						user
					end
				end

				# user.save
				# user
			end
			# end
		end
	end
