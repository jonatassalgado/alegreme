namespace :scrapy do

  require 'json'
  require 'open-uri'
  require 'net/http'

  task facebook: :environment do
    puts "Parsear JSON ****************************************"

    files = Dir['../scrapy/alegreme/*']
    last_file = (files.select{ |file| file[/events-\d{8}-\d{6}\.json$/] }).max
    current_file = File.read(last_file)
    data = JSON.parse(current_file)


    data.each do |item|

      puts "Criar lugar ****************************************"

      @place = Place.create_with({
        name: item['place'],
        address: item['address']
        }).find_or_create_by(name: item['place'])

        puts @place.inspect



      puts "Criar Evento ****************************************"

      if item['description']
        params = { query: item['description'] }
        uri = URI("http://localhost:5000/predict/event")
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
              }
            },
            categories: {
              primary: {
                name: predict['classification']['categories']['primary']['name'],
                score: predict['classification']['categories']['primary']['score']
              },
              secondary: {
                name: predict['classification']['categories']['secondary']['name'],
                score: predict['classification']['categories']['secondary']['score']
              }
            }
          ).find_or_create_by(source_url: item['source_url'])
        else
          @event = Event.create_with(
            name: item['name'],
            description: item['description'],
            source_url: item['source_url']
          ).find_or_create_by(source_url: item['source_url'])
        end

        if item['cover_url']
          begin
            cover = open(item['cover_url'])
            @event.cover.attach(io: cover, filename: "event#{@event.id}.jpg", content_type: "image/jpg")
          rescue OpenURI::HTTPError => ex
            puts "Erro no download de imagem cover do facebook: #{ex}"
          end
        end

        @place.events << @event unless @place.events.include?(@event)
        puts @event.inspect
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
