# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

kinds = ["noite", "bebida", "ar livre", "música", "bem-estar", "bicicleta", "skate", "aventura", "caminhada", "dança", "acadêmico", "profissional", "arte", "economia compartilhada"]

User.create(
	email: "test@gmail.com",
	features: { 
		"psychographic": {
			"personas": {
				"primary": {
					"name": "hipster", 
					"score": "1"
				}, 
				"tertiary": {
					"name": "underground", 
					"score": "1"
				}, 
				"secondary": {
					"name": "praieiro", 
					"score": "1"
				}, 
				"assortment": {
					"finished": false
				}, 
				"quartenary": {
					"name": "cult", 
					"score": "1"
				}
			}
		}
	},  
	admin: true
)

Artifact.create(
	details: {
		name: 'kinds',
		type: 'list'
	},
	data: {
		whitelist: kinds,
		blacklist: []
	}
)

Artifact.create(
	details: {
		name: 'tags',
		type: 'list'
	},
	data: {
		whitelist: {
			things: [],
			activities: [],
			features: []
		},
		blacklist: {
			things: [],
			activities: [],
			features: []
		}
	}
)

Artifact.create(
	details: {
		name: 'description',
		type: 'list'
	},
	data: {
		whitelist: [],
		blacklist: []
	}
)
