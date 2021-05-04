namespace :ml do

	require 'json'
	require 'open-uri'
	require 'net/http'
	require 'colorize'

	desc "Retreina todos os eventos com score abaixo de 0.9"
	task retrain: :environment do
		events_to_retrain = Event.active.where("( ml_data -> 'personas' -> 'primary' ->> 'score')::numeric < 0.90 AND (ml_data -> 'categories' -> 'primary' ->> 'score')::numeric < 0.90 AND (ml_data -> 'categories' -> 'primary' ->> 'name') != 'outlier' AND (ml_data -> 'personas' -> 'primary' ->> 'name') != 'outlier'").uniq

		events_to_retrain.each do |event|
			event_retrained = retrain_event event

			if event_retrained.save!
				puts "#{event_retrained.name} - Evento retreinado".green
			else
				puts "#{event_retrained.name} - Problema no retreino".red
			end
		end
	end

	def retrain_event(event)
		@label_query  = Base64.encode64(event.ml_data['stemmed'])
		@label_params = {query: @label_query}

		@label_uri       = URI("#{ENV['API_URL']}:5000/event/label")
		@label_uri.query = URI.encode_www_form(@label_params)

		@label_response = Net::HTTP.get_response(@label_uri)
		@label_data     = JSON.parse(@label_response.try(:body))

		@label_response_is_success = @label_response.is_a?(Net::HTTPSuccess)

		if @label_response_is_success
			event.ml_data.deep_merge!(
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
					}
			)

			if @label_data['classification']['categories']
				labels = @label_data['classification']['categories']

				categories = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name'], labels['secondary']['name']])
				event.categories << categories
			end

			return event
		else
			puts "Erro durante a classificação - #{event.name}".red
		end
	end
end
