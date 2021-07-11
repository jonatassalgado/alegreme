module Api
	class OmniauthController < ApplicationController
		# before_action :authenticate_user!, only: :members_only

		# Returned by validator.check
		#
		# {
		# 	"iss":            "https://accounts.google.com",
		# 	"azp":            "859257966270-4d46qno0cujh2rjti1babfi1s880pqhc.apps.googleusercontent.com",
		# 	"aud":            "859257966270-0drk2056dquiqtoljbhf8gtrajinqqfr.apps.googleusercontent.com",
		# 	"sub":            "110913456108098474743",
		# 	"email":          "test@gmail.com",
		# 	"email_verified": true,
		# 	"name":           "Jon",
		# 	"picture":        "https://lh3.googleusercontent.com/a-/AOh14GgwAEFRwFRpIGVdr3EqFYVf08o3FsXzUn9zRvf1Jw=s96-c",
		# 	"given_name":     "Jon",
		# 	"locale":         "pt-BR",
		# 	"iat":            1623955609,
		# 	"exp":            1623959209,
		# 	"cid":            "859257966270-4d46qno0cujh2rjti1babfi1s880pqhc.apps.googleusercontent.com"
		# }

		def google_oauth2
			validator = GoogleIDToken::Validator.new
			azp       = '859257966270-4d46qno0cujh2rjti1babfi1s880pqhc.apps.googleusercontent.com'
			aud       = '859257966270-0drk2056dquiqtoljbhf8gtrajinqqfr.apps.googleusercontent.com'
			begin
				payload = validator.check(params[:id_token].to_s, aud)

				if payload['aud'] != aud && payload['azp'] != azp
					render json: 'aud/azp is invalid' and return
				elsif payload['email_verified'] == false
					render json: 'email is not verified' and return
				else
					user = User.find_by_email payload['email']

					unless user
						user = User.new(email:    payload['email'],
														password: Devise.friendly_token[0, 20],
														provider: 'google')

						user.features.deep_merge!({
																				'demographic' => {
																					'name'    => payload['given_name'],
																					'picture' => payload['picture'],
																					'social'  => {
																						'googleId' => payload['sub']
																					},
																				}
																			})

						if payload['picture']
							begin
								user_picture = Down.download(payload['picture'])
							rescue Down::Error => e
								puts "#{payload['given_name']} - Erro no download da imagem (#{payload['picture']}) - #{e}"
							else
								user.image = user_picture
								puts "#{payload['given_name']} - Download da imagem (#{payload['picture']}) - Sucesso"
							end
						end
					end

					devise_token = user.create_token
					user.save

					render json: {
						'token':        {
							'client':       devise_token['client'],
							'access_token': devise_token['token'],
							'uid':          payload['email'],
							'expiry_date':  DateTime.strptime(payload['exp'].to_s, "%s").iso8601
						},
						'current_user': {
							id:       user.id,
							name:     user.features.dig('demographic', 'name'),
							email:    user.email,
							slug:     user.slug,
							picture:  user.features.dig('demographic', 'picture'),
							provider: user.provider
						}
					}
				end
			rescue GoogleIDToken::ValidationError => e
				render json: e
			end
		end
	end
end

