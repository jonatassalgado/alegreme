require 'colorize'

namespace :push do
	desc 'Envia push para usuários sobre os novos eventos adicionados no dia'
	task new_events_today: :environment do

		puts "Task push:new_events_today iniciada em #{DateTime.now}}".white

		pushy_app = Rpush::Pushy::App.find_by_name("Alegreme")

		unless pushy_app
			app             = Rpush::Pushy::App.new
			app.name        = 'Alegreme'
			app.api_key     = Rails.application.credentials[Rails.env.to_sym][:pushy][:api_key]
			app.connections = 1
			app.save!
		end

		events_count = Event.where("created_at > ?", DateTime.now - 1).size
		users        = User.where("(notifications -> 'topics' -> 'all' ->> 'active')::boolean")

		users.each do |user|
			user_suggestions_count = Event.where("created_at > ?", DateTime.now.beginning_of_day - 1).with_high_score.in_user_personas(user).size

			if user_suggestions_count >= 2
				user.notifications_devices.each do |device|
					notification                  = Rpush::Pushy::Notification.new
					notification.app              = pushy_app || Rpush::Pushy::App.find_by_name("Alegreme")
					notification.registration_ids = device
					notification.data             = {
							title:   "Oi #{user.first_name}",
							message: "Foram adicionados #{events_count} eventos hoje, separamos #{user_suggestions_count} que você pode gostar.",
							url:     "https://www.alegreme.com",
							image:   "https://alegreme.sfo2.digitaloceanspaces.com/stable-images/push-icon-192x192.png",
							badge:   "https://alegreme.sfo2.digitaloceanspaces.com/stable-images/bagde-alpha-72x72.png",
							actions: [{
									          action: 'open-app',
									          title:  "Ver Agora"
							          }]
					}
					notification.time_to_live     = 14400
					if notification.save!
						puts "Notificação agendada para #{user.id} no device #{device}".white
					else
						puts "Ocorreu algum problema ao criar a notificação para #{user.id} no device #{device}".red
					end
				end
			else
				puts "Usuário sem eventos novos - Apenas #{user_suggestions_count} novos".yellow
			end
		end

		Rpush.push
		Rpush.apns_feedback

		puts "Task push:new_events_today finalizada em #{DateTime.now}}".white
		puts "Notificações agendadas para #{users.size} usuários".green

	end
end
