namespace :launch do

	task users: :environment do

		fake_users = [
				{
						email:   'fake1@gmail.com',
						name:    'User Silva',
						picture: "welcome/fk-users/Ellipse-1.jpg"
				},
				{
						email:   'fake2@gmail.com',
						name:    'Marcelo Englert',
						picture: "welcome/fk-users/Ellipse-2.jpg"
				},
				{
						email:   'fake3@gmail.com',
						name:    'Juliana Mello',
						picture: "welcome/fk-users/Ellipse-3.jpg"
				},
				{
						email:   'fake4@gmail.com',
						name:    'Pietra R. Godoy ',
						picture: "welcome/fk-users/Ellipse-4.jpg"
				},
				{
						email:   'fake5@gmail.com',
						name:    'Henrique Salazar',
						picture: "welcome/fk-users/Ellipse-5.jpg"
				},
				{
						email:   'fake6@gmail.com',
						name:    'Gustavo da Silva',
						picture: "welcome/fk-users/Ellipse-6.jpg"
				},
				{
						email:   'fake7@gmail.com',
						name:    'Enzo',
						picture: "welcome/fk-users/Ellipse-7.jpg"
				},
				{
						email:   'fake8@gmail.com',
						name:    'Patrícia Pereira',
						picture: "welcome/fk-users/Ellipse-8.jpg"
				},
				{
						email:   'fake9@gmail.com',
						name:    'Emilaine Henrich',
						picture: "welcome/fk-users/Ellipse-9.jpg"
				}
		]


		fake_users.each do |fake_user|

			user = User.new(email:    fake_user[:email],
			                password: Devise.friendly_token[0, 20])
			user.features.deep_merge!({
					                         'demographic' => {
							                         'name'    => fake_user[:name],
							                         'picture' => fake_user[:picture]
					                         }
			                         })

			user.save!

		end

	end
end