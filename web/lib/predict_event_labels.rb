require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'
require 'timecop'

module PredictEventLabels
	class << self

		def predict event
			get_features_of_event(event)
			classify_event(event)
			save_event(event)
		end

		private

		def get_features_of_event(event)
			puts "#{event.name} #{event.id} - Adicionando features".white
			features_query  = event.text_to_ml
			features_params = { 'query' => features_query }

			features_uri = URI("#{ENV['API_URL']}:5000/event/features")

			features_response = Net::HTTP.post_form(features_uri, features_params)
			features_data     = JSON.parse(features_response.try(:body))

			features_response_is_success = features_response.is_a?(Net::HTTPSuccess)

			if features_response_is_success
				event.ml_data.deep_merge!(
					stemmed: features_data['stemmed']
				)
			else
				puts "#{event.name} #{event.id} - Erro durante a extração de features".red
			end
		end

		def classify_event(event)
			puts "#{event.name} #{event.id} - Adicionando classificação".white
			label_query  = event.text_to_ml
			label_params = { 'query' => label_query }

			label_uri = URI("#{ENV['API_URL']}:5000/event/label")

			label_response = Net::HTTP.post_form(label_uri, label_params)
			label_data     = JSON.parse(label_response.try(:body))

			label_response_is_success = label_response.is_a?(Net::HTTPSuccess)

			if label_response_is_success

				event.ml_data.deep_merge!(
					content_rules: {
						annotations: [],
						predictions: label_data['classification']['content_rules']
					},
					personas:      {
						annotations: [],
						predictions: [
													 {
														 model_version: DateTime.now.strftime("persona-%Y%m%d-%H%M%S"),
														 result:        [
																							{
																								from_name: "persona",
																								to_name:   "description",
																								type:      "choices",
																								value:     {
																									choices: [
																														 label_data['classification']['personas']['primary']['name']
																													 ]
																								}
																							}
																						],
														 score:         label_data['classification']['personas']['primary']['score']
													 }
												 ]
					},
					categories:    {
						annotations: [],
						predictions: [
													 {
														 model_version: DateTime.now.strftime("category-%Y%m%d-%H%M%S"),
														 result:        [
																							{
																								from_name: "category",
																								to_name:   "description",
																								type:      "choices",
																								value:     {
																									choices: [
																														 label_data['classification']['categories']['primary']['name']
																													 ]
																								}
																							}
																						],
														 score:         label_data['classification']['categories']['primary']['score']
													 }
												 ]
					},
					price:         {
						annotations: [],
						predictions: [
													 {
														 model_version: DateTime.now.strftime("price-%Y%m%d-%H%M%S"),
														 result:        [
																							{
																								from_name: "price",
																								to_name:   "description",
																								type:      "choices",
																								value:     {
																									choices: [
																														 label_data['classification']['price']['name']
																													 ]
																								}
																							}
																						],
														 score:         label_data['classification']['price']['score']
													 }
												 ]
					}
				)

				if label_data['classification']['categories']
					labels           = label_data['classification']['categories']
					categories       = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name']])

					event.categories = [] if event.categories.present?
					event.categories << categories
					puts "#{event.name} #{event.id} - Evento classificado - (#{label_data['classification']['content_rules'][0]['result'][0]['value']['choices'][0]} / #{labels['primary']['name']})".white
				end

			else
				puts "#{event.name} #{event.id} - Erro durante a classificação".red
			end
		end

		def save_event(event)
			if event.save!
				puts "#{event.id}, #{event.name[0..60]} - Salvo!".green
				true
			end
		end
	end

end


