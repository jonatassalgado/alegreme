namespace :scrapy do
  require "json"
  require "open-uri"
  require "net/http"
  require "down"

  require_relative "../geographic"
  require_relative "../../config/initializers/shrine"
  require_relative "../../app/uploaders/image_uploader"

  uploader = ImageUploader.new(:store)

  namespace :facebook do
    task create: :environment do
      puts "Parsear JSON ****************************************"
  
      if ENV["IS_DOCKER"] == "true"
        files = Dir["/var/www/scrapy/data/scraped/*"]
      else
        files = Dir["../scrapy/scraped/*"]
      end
      last_file = (files.select { |file| file[/events-\d{8}-\d{6}\.json$/] }).max
      current_file = File.read(last_file)
      data = JSON.parse(current_file)
  
      data.each do |item|
        puts "Criar lugar ****************************************"
        geocode = Geocoder.search(Alegreme::Geographic.get_cep_from_address(item["address"])).first if item["address"]
        place_not_exist_yet = Place.where.contains(details: { name: item["place"] }).blank?
  
        if place_not_exist_yet
          @place = Place.create({
            details: {
              name: item["place"],
            },
            geographic: {
              address: item["address"],
              latlon: geocode.try(:coordinates),
              neighborhood: geocode.try(:suburb),
              city: item["address"] ? item["address"][/Porto Alegre/] : nil,
              cep: Alegreme::Geographic.get_cep_from_address(item["address"]),
            },
          })
  
          puts @place.inspect
        end
  
        puts "Criar Evento ****************************************"
  
        if item["description"]
          query = Base64.encode64(item["description"])
          features_params = { query: query }
          
          event_not_exist_yet = Event.where.contains(details: { source_url: item["source_url"] }).blank?
          
          features_uri = URI("#{ENV["API_URL"]}:5000/event/features")
          features_uri.query = URI.encode_www_form(features_params)
          
          features_response = Net::HTTP.get_response(features_uri)
          ml_data = JSON.parse(features_response.body) if features_response.is_a?(Net::HTTPSuccess)
  
          features_response_is_success = features_response.is_a?(Net::HTTPSuccess)

          if event_not_exist_yet && features_response_is_success
            @event = Event.new(
              details: {
                name: item["name"],
                description: item["description"],
                source_url: item["source_url"],
                prices: item["prices"] ? item["prices"] : [],
              },
              ocurrences: {
                dates: item["datetimes"],
              },
              ml_data: {
                cleanned: ml_data['cleanned'],
                stemmed: ml_data['stemmed'],
                freq: ml_data['freq'],
                nouns: ml_data['nouns'],
                verbs: ml_data['verbs'],
                adjs: ml_data['adjs']
              },
              geographic: {
                address: item["address"],
                latlon: geocode.try(:coordinates),
                neighborhood: geocode.try(:suburb),
                city: item["address"] ? item["address"][/Porto Alegre/] : nil,
                cep: Alegreme::Geographic.get_cep_from_address(item["address"]),
              }
            )
  
            if @event && @place
              if item["cover_url"]
                begin
                  event_name = "event-#{item["name"].parameterize}"
                  event_cover_file = Down.download(item["cover_url"])
                  @event.image = uploader.upload(event_cover_file, metadata: { "filename" => event_name })
                rescue Down::Error => ex
                  puts "Erro no download de imagem cover do facebook: #{ex}"
                end
              end
    
              @place.events << @event unless @place.events.include?(@event)
    
              puts "Criar organizador ****************************************"
    
              item["organizers"].try(:each) do |organizer|
                @organizer = Organizer.create_with({
                  name: item["organizer"],
                  source_url: item["organizer_url"],
                }).find_or_create_by(name: organizer)
    
                @event.organizers << @organizer unless @event.organizers.include?(@organizer)
                puts organizer.inspect
              end
              
              puts "Classificar ****************************************"
              
              label_query = Base64.encode64(ml_data['stemmed'])
              label_params = { query: label_query }
  
              label_uri = URI("#{ENV["API_URL"]}:5000/event/label")
              label_uri.query = URI.encode_www_form(label_params)
              
              label_response = Net::HTTP.get_response(label_uri)
              label_data = JSON.parse(label_response.body) if label_response.is_a?(Net::HTTPSuccess)
      
              label_response_is_success = label_response.is_a?(Net::HTTPSuccess)
  
              if label_response_is_success
                @event['personas'] = {
                  primary: {
                    name: label_data["classification"]["personas"]["primary"]["name"],
                    score: label_data["classification"]["personas"]["primary"]["score"],
                  },
                  secondary: {
                    name: label_data["classification"]["personas"]["secondary"]["name"],
                    score: label_data["classification"]["personas"]["secondary"]["score"],
                  },
                  outlier: false,
                }
  
                @event['categories'] = {
                  primary: {
                    name: label_data["classification"]["categories"]["primary"]["name"],
                    score: label_data["classification"]["categories"]["primary"]["score"],
                  },
                  secondary: {
                    name: label_data["classification"]["categories"]["secondary"]["name"],
                    score: label_data["classification"]["categories"]["secondary"]["score"],
                  },
                  outlier: false,
                }
  
                @event.save!
  
                puts @event.try(:inspect)
  
              else
                puts "CLASSIFICAÇÃO NÃO REALIZADA"
              end
            end
          else
            puts "NĂO FOI POSSÍVEL CRIAR O EVENTO"
          end
        end
      end
    end


    task similar: :environment do
      puts "Similares ****************************************"
      
      active_events = Event.all.active
      base_to_compare = active_events.map{|event| [event.ml_data['stemmed'], event.id]}
  
      active_events.each_with_index do |event, index|
        similar_params = { text: index, base: Base64.encode64(base_to_compare.to_s) }
    
        similar_uri = URI("#{ENV["API_URL"]}:5000/event/similar")
        similar_uri.query = URI.encode_www_form(similar_params)
        
        similar_response = Net::HTTP.get_response(similar_uri)
        similar_data = JSON.parse(similar_response.body) if similar_response.is_a?(Net::HTTPSuccess)
    
        similar_response_is_success = similar_response.is_a?(Net::HTTPSuccess)
    
        if similar_response_is_success
          puts "SIMILARES AO EVENTO #{event.id} SÃO OS EVENTOS #{similar_data}"
          event.update_attribute :similar_data, similar_data
        else
          puts "SIMILARES NÃO ENCONTRADOS"
        end
      end
    end

  end
  
end
