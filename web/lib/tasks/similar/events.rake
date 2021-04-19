namespace :similar do
  desc 'Definir eventos similares para todos os eventos ativos'
	task events: :environment do
		active_events   = Event.all.active.where("(ml_data ->> 'stemmed') IS NOT NULL")
		base_to_compare = active_events.map { |event| [event.ml_data['stemmed'], event.id] }.to_json

		active_events.each_with_index do |event, index|
			similar_params   = {'text' => index, 'base' => base_to_compare}
			similar_uri      = URI("#{ENV["API_URL"]}:5000/event/similar")
			similar_response = Net::HTTP.post_form(similar_uri, similar_params)
			similar_data     = JSON.parse(similar_response.body) if similar_response.is_a?(Net::HTTPSuccess)

			similar_response_is_success = similar_response.is_a?(Net::HTTPSuccess)

			if similar_response_is_success
				puts "#{similar_data} - Similares ao evento #{event.id}".blue
				event.update_attribute :similar_data, similar_data
				puts "#{event.details['name'][0..60]} - Similares salvos".green
			else
				puts "Eventos similares não encontrados".yellow
			end
		end
	end
end