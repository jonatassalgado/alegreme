# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

kinds = ["noite", "bebida", "ar livre", "música", "bem-estar", "bicicleta", "skate", "aventura", "caminhada", "dança", "acadêmico", "profissional", "arte", "economia compartilhada"]
categories = ['anúncio', 'festa', 'curso', 'teatro', 'show', 'cinema', 'exposição', 'feira', 'esporte', 'meetup', 'hackaton', 'palestra', 'sarau', 'festival', 'brecho', 'fórum', 'slam', 'protesto', 'outlier']

User.create(
		email:    "test@gmail.com",
		password: "123456",
		features: {
				"psychographic": {
						"personas": {
								"primary":    {
										"name":  "hipster",
										"score": "1"
								},
								"tertiary":   {
										"name":  "underground",
										"score": "1"
								},
								"secondary":  {
										"name":  "praieiro",
										"score": "1"
								},
								"assortment": {
										"finished": false
								},
								"quartenary": {
										"name":  "cult",
										"score": "1"
								}
						}
				},
				'demographic' => {
						'name'    => 'Admin',
						'beta'    => {
								'requested' => true,
								'activated' => true
						}
				}
		},
		admin:    true
)

puts "test@gmail.com 123456 - Usuário administrador criado".blue

kinds.each do |kind|
	kind = Kind.create!(details: {name: kind})
	puts "#{kind.details['name']} - Tipo criado".green
end

categories.each do |category|
  category = Category.create!(details: {
		  name: category
  })
	puts "#{category.details['name']} - Categoria criada".green
end

Artifact.create!(
		details: {
				name: 'kinds',
				type: 'list'
		},
		data:    {
				whitelist: kinds,
				blacklist: []
		}
)

Artifact.create!(
		details: {
				name: 'tags',
				type: 'list'
		},
		data:    {
				whitelist: {
						things:     [],
						activities: [],
						features:   []
				},
				blacklist: {
						things:     [],
						activities: [],
						features:   []
				}
		}
)

Artifact.create!(
		details: {
				name: 'description',
				type: 'list'
		},
		data:    {
				whitelist: [],
				blacklist: []
		}
)

#
# fake_users = [
# 		{
# 				email:   'fake1@gmail.com',
# 				name:    'User Silva',
# 				picture: "welcome/fk-users/Ellipse-1.jpg"
# 		},
# 		{
# 				email:   'fake2@gmail.com',
# 				name:    'Marcelo Englert',
# 				picture: "welcome/fk-users/Ellipse-2.jpg"
# 		},
# 		{
# 				email:   'fake3@gmail.com',
# 				name:    'Juliana Mello',
# 				picture: "welcome/fk-users/Ellipse-3.jpg"
# 		},
# 		{
# 				email:   'fake4@gmail.com',
# 				name:    'Pietra R. Godoy ',
# 				picture: "welcome/fk-users/Ellipse-4.jpg"
# 		},
# 		{
# 				email:   'fake5@gmail.com',
# 				name:    'Henrique Salazar',
# 				picture: "welcome/fk-users/Ellipse-5.jpg"
# 		},
# 		{
# 				email:   'fake6@gmail.com',
# 				name:    'Gustavo da Silva',
# 				picture: "welcome/fk-users/Ellipse-6.jpg"
# 		},
# 		{
# 				email:   'fake7@gmail.com',
# 				name:    'Enzo',
# 				picture: "welcome/fk-users/Ellipse-7.jpg"
# 		},
# 		{
# 				email:   'fake8@gmail.com',
# 				name:    'Patrícia Pereira',
# 				picture: "welcome/fk-users/Ellipse-8.jpg"
# 		},
# 		{
# 				email:   'fake9@gmail.com',
# 				name:    'Emilaine Henrich',
# 				picture: "welcome/fk-users/Ellipse-9.jpg"
# 		}
# ]
#
#
# fake_users.each do |fake_user|
#
# 	user = User.new(email:    fake_user[:email],
# 									password: Devise.friendly_token[0, 20])
# 	user.features.deep_merge!({
# 															 'demographic' => {
# 																	 'name'    => fake_user[:name],
# 																	 'picture' => fake_user[:picture]
# 															 }
# 													 })
#
# 	user.save!
#
# 	puts "#{fake_user[:name]} - Usuário criado".green
# end

puts "Usuários criados com sucesso"
