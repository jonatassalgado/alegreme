namespace :scrapy do

  require 'json'
  require 'open-uri'
  require 'net/http'

  require_relative '../geographic'

  task facebook: :environment do
    puts "Parsear JSON ****************************************"

    if ENV['IS_DOCKER'] == 'true'
      files = Dir['/var/www/scrapy/data/*']
    else
      files = Dir['./scrapy/*']
    end
    last_file = (files.select{ |file| file[/events-\d{8}-\d{6}\.json$/] }).max
    current_file = File.read(last_file)
    data = JSON.parse(current_file)


    data.each do |item|

      puts "Criar lugar ****************************************"
      geocode = Geocoder.search(Alegreme::Geographic.get_cep_from_address(item['address'])).first if item['address']

      @place = Place.create_with({
        name: item['place'],
        geographic: {
          address: item['address'],
          latlon: geocode.try(:coordinates),
          neighborhood: geocode.try(:suburb),
          city: item['address'] ? item['address'][/Porto Alegre/] : nil,
          cep: Alegreme::Geographic.get_cep_from_address(item['address'])
        }
        }).find_or_create_by(name: item['place'])

        puts @place.inspect



      puts "Criar Evento ****************************************"

      if item['description']
        query = Base64.encode64(item['description'])
        params = { query: query }
        uri = URI("#{ENV['API_URL']}:5000/predict/event")
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        predict = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

        if response.is_a?(Net::HTTPSuccess)

          @event = Event.create_with(
            name: item['name'],
            description: item['description'],
            source_url: item['source_url'],
            ocurrences: {
              dates: item['datetimes']
            },
            personas: {
              primary: {
                name: predict['classification']['personas']['primary']['name'],
                score: predict['classification']['personas']['primary']['score']
              },
              secondary: {
                name: predict['classification']['personas']['secondary']['name'],
                score: predict['classification']['personas']['secondary']['score']
              },
              outlier: false
            },
            categories: {
              primary: {
                name: predict['classification']['categories']['primary']['name'],
                score: predict['classification']['categories']['primary']['score']
              },
              secondary: {
                name: predict['classification']['categories']['secondary']['name'],
                score: predict['classification']['categories']['secondary']['score']
              },
              outlier: false
            },
            geographic: {
              address: item['address'],
              latlon: geocode.try(:coordinates),
              neighborhood: geocode.try(:suburb),
              city: item['address'] ? item['address'][/Porto Alegre/] : nil,
              cep: Alegreme::Geographic.get_cep_from_address(item['address'])
            }
          ).find_or_create_by(source_url: item['source_url'])
        else
          puts 'NÃO FOI POSSÍVEL CRIAR O EVENTO'
          # @event = Event.create_with(
          #   name: item['name'],
          #   description: item['description'],
          #   source_url: item['source_url']
          # ).find_or_create_by(source_url: item['source_url'])
        end

        if item['cover_url']
          begin
            cover = open(item['cover_url'])
            @event.cover.attach(io: cover, filename: "event#{@event.id}.jpg", content_type: "image/jpeg")
          rescue OpenURI::HTTPError => ex
            puts "Erro no download de imagem cover do facebook: #{ex}"
          end
        end

        @place.events << @event unless @place.events.include?(@event)
        puts @event.try(:inspect)
      end





      puts "Criar organizador ****************************************"

      item['organizers'].try(:each) do |organizer|
        @organizer = Organizer.create_with({
          name: item['organizer'],
          source_url: item['organizer_url']
        }).find_or_create_by(name: organizer)

        @event.organizers << @organizer unless @event.organizers.include?(@organizer)
        puts organizer.inspect
      end


    end

  end

end
