require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'
require 'timecop'

module PredictEventsLabelsRake

	def get_features_of_event(event)
		features_query  = event.text_to_ml
		features_params = { 'query' => features_query }

		features_uri = URI("#{ENV['API_URL']}:5000/event/features")

		features_response = Net::HTTP.post_form(features_uri, features_params)
		features_data     = JSON.parse(features_response.try(:body))

		features_response_is_success = features_response.is_a?(Net::HTTPSuccess)

		if features_response_is_success
			puts "#{event.details_name} #{event.id} - Adicionando features".white
			event.ml_data.deep_merge!(
				'stemmed' => features_data['stemmed']
			)
		else
			puts "#{event.details_name} #{event.id} - Erro durante a extração de features".red
		end
	end

	def classify_event(event)
		label_query  = event.details_description
		label_params = { 'query' => label_query }

		label_uri = URI("#{ENV['API_URL']}:5000/event/label")

		label_response = Net::HTTP.post_form(label_uri, label_params)
		label_data     = JSON.parse(label_response.try(:body))

		label_response_is_success = label_response.is_a?(Net::HTTPSuccess)

		if label_response_is_success
			puts "#{event.details_name} #{event.id} - Adicionando classificação".white
			data = {
				personas:   {
					primary:   {
						name:  label_data['classification']['personas']['primary']['name'],
						score: label_data['classification']['personas']['primary']['score']
					},
					secondary: {
						name:  label_data['classification']['personas']['secondary']['name'],
						score: label_data['classification']['personas']['secondary']['score']
					},
					outlier:   false
				},
				categories: {
					primary:   {
						name:  label_data['classification']['categories']['primary']['name'],
						score: label_data['classification']['categories']['primary']['score']
					},
					secondary: {
						name:  label_data['classification']['categories']['secondary']['name'],
						score: label_data['classification']['categories']['secondary']['score']
					},
					outlier:   false
				},
				price: {
					name:  label_data['classification']['price']['name'],
					score: label_data['classification']['price']['score']
				}
			}

			event.ml_data.deep_merge!(data)

			if label_data['classification']['categories']
				labels     = label_data['classification']['categories']
				categories = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name']])
				
				event.categories = [] if event.categories.present?
				event.categories << categories
				puts "#{event.details_name} #{event.id} - Evento classificado - (#{labels['primary']['name']})".white
			end

		else
			puts "#{event.details_name} #{event.id} - Erro durante a classificação".red
		end
	end

	def save_event(event)
		if event.save!
			puts "#{event.id}, #{event.details['name'][0..60]} - Salvo!".green
			true
		end
	end

end

namespace :ml do
	namespace :predict do
		desc 'Predict event labels'
		task events: :environment do
	
			include PredictEventsLabelsRake

			puts "\n Task ml:predict:events iniciada em #{DateTime.now} \n".blue
	
			Event.active.order_by_date.limit(100).each_with_index do |event, index|
				puts "#{index}: #{event.details_name[0..60]} \n ---------------------------------"
				get_features_of_event(event)
				classify_event(event)
				save_event(event)
				puts "\n\n"
			end
	
			puts "\n Task ml:predict:events finalizada em #{DateTime.now}} \n".blue
	
		end
	end
end
