namespace :scrapy do
  require "json"
  require "open-uri"
  require "net/http"
  require "down"

  require_relative "../geographic"
  require_relative "../../config/initializers/shrine"
  require_relative "../../app/uploaders/image_uploader"

  uploader = ImageUploader.new(:store)

  task facebook: :environment do
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
        params = { query: query }
        uri = URI("#{ENV["API_URL"]}:5000/predict/event")
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        predict = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
        
        event_not_exist_yet = Event.where.contains(details: { source_url: item["source_url"] }).blank?
        ml_response_is_success = response.is_a?(Net::HTTPSuccess)

        if ml_response_is_success && event_not_exist_yet
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
            personas: {
              primary: {
                name: predict["classification"]["personas"]["primary"]["name"],
                score: predict["classification"]["personas"]["primary"]["score"],
              },
              secondary: {
                name: predict["classification"]["personas"]["secondary"]["name"],
                score: predict["classification"]["personas"]["secondary"]["score"],
              },
              outlier: false,
            },
            categories: {
              primary: {
                name: predict["classification"]["categories"]["primary"]["name"],
                score: predict["classification"]["categories"]["primary"]["score"],
              },
              secondary: {
                name: predict["classification"]["categories"]["secondary"]["name"],
                score: predict["classification"]["categories"]["secondary"]["score"],
              },
              outlier: false,
            },
            geographic: {
              address: item["address"],
              latlon: geocode.try(:coordinates),
              neighborhood: geocode.try(:suburb),
              city: item["address"] ? item["address"][/Porto Alegre/] : nil,
              cep: Alegreme::Geographic.get_cep_from_address(item["address"]),
            },
          )
          puts @event.try(:inspect)
        else
          puts "NÃO FOI POSSÍVEL CRIAR O EVENTO"
          # @event = Event.create_with(
          #   name: item['name'],
          #   description: item['description'],
          #   source_url: item['source_url']
          # ).find_or_create_by(source_url: item['source_url'])
        end

        if @event && @place
          if item["cover_url"]
            begin
              event_name = "event-#{item["name"].parameterize}"
              event_cover_file = Down.download(item["cover_url"])
              @event.image = uploader.upload(event_cover_file, metadata: { "filename" => event_name })

              # require 'down'
              # uploader = ImageUploader.new(:store)
              # @event = Event.new
              # event_name = "event-#{"SADSA dsadsa sd".parameterize}"
              # event_cover_file = Down.download("https://scontent.fpoa12-1.fna.fbcdn.net/v/t1.0-9/s851x315/45818886_739571639728842_5669269685833564160_n.jpg?_nc_cat=102&_nc_ht=scontent.fpoa12-1.fna&oh=3e347b8687b90b3acd35521150f4f51e&oe=5D29543E")
              # @event.image = uploader.upload(event_cover_file, metadata: {"filename" => event_name})
              # @event.place = Place.new name: 'aaa'
              # @event.save!
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

          @event.save!
        end
      end
    end
  end
end
