namespace :ml do

	require 'json'
	require 'open-uri'
	require 'net/http'
	require 'colorize'

	task train: :environment do

		if ENV['IS_DOCKER'] == 'true'
			files = Dir['/var/www/scrapy/data/classified/*']
		else
			files = Dir['../scrapy/classified/*']
		end
		last_file = (files.select { |file| file[/svm-classification-events-\d{8}-\d{6}\.csv$/] }).max
		csv       = CSV.read(last_file)

		puts "Abrindo o arquivo #{last_file}".blue

		events = Event.where("( ml_data -> 'personas' -> 'primary' ->> 'score')::numeric >= 0.90 OR (ml_data -> 'categories' -> 'primary' ->> 'score')::numeric >= 0.90").order("updated_at ASC").uniq


		events.each do |event|
			item = csv.find { |row| row[7] == event.details['source_url'] }
			if item
				puts "Atualizando #{event.details['name']}...".blue

				item[8]  = event.personas_primary_name
				item[9]  = event.theme['name']
				item[10] = event.categories_primary_name
				item[11] = event.kinds_name
				item[12] = event.tags_things
				item[13] = event.tags_activities
				item[14] = event.tags_features
			else
				puts "Adicionando #{event.details['name']}...".green

				csv << [
						event.details['name'],
						event.geographic['address'],
						event.datetimes,
						event.place_details_name,
						event.organizers.pluck("details ->> 'name'"),
						event.details['description'],
						nil,
						event.details['source_url'],
						event.personas_primary_name,
						event.theme['name'],
						event.categories_primary_name,
						event.kinds_name,
						event.tags_things,
						event.tags_activities,
						event.tags_features]

			end
		end


		timestr  = DateTime.now.strftime("%Y%m%d-%H%M%S")
		artifact = Artifact.create(
				details: {
						name: "svm-classification-events-#{timestr}",
						type: 'ml-classified'
				}
		)

		if ENV['IS_DOCKER'] == 'true'
			CSV.open('/var/www/scrapy/data/classified/svm-classification-events-' + timestr + '.csv', 'wb') do |row|
				csv.each do |item|
					row << item
				end
			end
			artifact.file.attach(io: File.open("/var/www/scrapy/data/classified/svm-classification-events-#{timestr}.csv"), filename: "svm-classification-events-#{timestr}.csv", content_type: "text/csv")
		else
			CSV.open('../scrapy/classified/svm-classification-events-' + timestr + '.csv', 'wb') do |row|
				csv.each do |item|
					row << item
				end
			end
			artifact.file.attach(io: File.open("../scrapy/classified/svm-classification-events-#{timestr}.csv"), filename: "svm-classification-events-#{timestr}.csv", content_type: "text/csv")
		end

		puts "Artefato criado: svm-classification-events-#{timestr}".green
	end
end
