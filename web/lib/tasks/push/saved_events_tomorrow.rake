require 'colorize'

namespace :push do
	desc 'Envia push para usuários avisando dos eventos salvos'
	task saved_events_tomorrow: :environment do

		pushy_app = Rpush::Pushy::App.find_by_name("Alegreme")

		unless pushy_app
			app             = Rpush::Pushy::App.new
			app.name        = 'Alegreme'
			app.api_key     = Rails.application.credentials[Rails.env.to_sym][:pushy][:api_key]
			app.connections = 1
			app.save!
		end

		users_to_notify              = []
		users_with_saved_events      = User.select("features, taste, notifications").with_notifications_actived.with_saved_events
		events_occuring_tomorrow_ids = Event.select("id").in_days([Date.tomorrow.to_s]).map(&:id)

		users_with_saved_events.each do |user|
			if user.saved_events_ids.any? { |saved| events_occuring_tomorrow_ids.include?(saved) }
				users_to_notify << user
			end
		end

		users_to_notify.each do |user|
			user.notifications_devices.each do |device|
				notification                  = Rpush::Pushy::Notification.new
				notification.app              = pushy_app || Rpush::Pushy::App.find_by_name("Alegreme")
				notification.registration_ids = device
				notification.data             = {
						title:   "Oi #{user.first_name}",
						message: "Só para avisar que você tem eventos salvos que acontecem amanhã. Dá uma olhada.",
						url:     "https://www.alegreme.com",
						image:   "https://alegreme.sfo2.digitaloceanspaces.com/stable-images/push-icon-192x192.png",
						badge:   "https://alegreme.sfo2.digitaloceanspaces.com/stable-images/bagde-alpha-72x72.png",
						actions: [{
								          action: 'open-app',
								          title:  "Ver Eventos"
						          }]
				}
				notification.time_to_live     = 18000
				notification.save!
			end
		end

		Rpush.push
		Rpush.apns_feedback

		puts "Notificações agendadas para #{users_to_notify.size} usuários".green

	end
end
