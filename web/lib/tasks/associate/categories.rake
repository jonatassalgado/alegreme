require 'colorize'
require 'json'

namespace :associate do
	desc 'Associar categorias aos eventos'
	task categories: :environment do

		events = Event.active

		events.each do |event|
			if event.ml_data['categories']
				labels = event.ml_data['categories']
				categories = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name'], labels['secondary']['name']])

				event.categories << categories

				if event.save!
					puts "Evento associado - #{event.details_name} #{event.categories_primary_name}".green
				else
					puts "Erro ao associar evento - #{event.details_name}".red
				end
			end
		end
	end
end
