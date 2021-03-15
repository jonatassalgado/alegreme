require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

module PredictEventsLabelsRake


	def save_event(event)
		if event.save!
			puts "Evento: #{event.id}, #{event.details['name'][0..60]} - Salvo!".green
			true
		end
	end

	def classify_event(event)
		@label_query  = event.details_description
		@label_params = { 'query' => @label_query }

		@label_uri = URI("#{ENV['API_URL']}:5000/event/label")

		@label_response = Net::HTTP.post_form(@label_uri, @label_params)
		@label_data     = JSON.parse(@label_response.try(:body))

		@label_response_is_success = @label_response.is_a?(Net::HTTPSuccess)

		if @label_response_is_success
			puts "Evento: #{event.details_name} - Adicionando classificação".white
			data = {
				personas:   {
					primary:   {
						name:  @label_data['classification']['personas']['primary']['name'],
						score: @label_data['classification']['personas']['primary']['score']
					},
					secondary: {
						name:  @label_data['classification']['personas']['secondary']['name'],
						score: @label_data['classification']['personas']['secondary']['score']
					},
					outlier:   false
				},
				categories: {
					primary:   {
						name:  @label_data['classification']['categories']['primary']['name'],
						score: @label_data['classification']['categories']['primary']['score']
					},
					secondary: {
						name:  @label_data['classification']['categories']['secondary']['name'],
						score: @label_data['classification']['categories']['secondary']['score']
					},
					outlier:   false
				},
				price: {
					name:  @label_data['classification']['price']['name'],
					score: @label_data['classification']['price']['score']
				}
			}

			puts "Associando #{data} - ao evento #{event.details_name}".white

			event.ml_data.deep_merge!(data)

			event.categories = [] if event.categories.present?

			if @label_data['classification']['categories']
				labels     = @label_data['classification']['categories']
				categories = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name']])
				
				event.categories << categories
			end

		else
			puts "Evento: #{event.details_name} - Erro durante a classificação".red
		end
	end

end

namespace :ml do
	namespace :predict do
		desc 'Predict event labels'
		task events: :environment do
	
			include PredictEventsLabelsRake
	
			puts "Task ml:predict:events iniciada em #{DateTime.now}".white
	
			Event.active.each do |event|
				classify_event(event)
				save_event(event)
			end
	
			puts "Task ml:predict:events finalizada em #{DateTime.now}}".white
	
		end
	end
end
