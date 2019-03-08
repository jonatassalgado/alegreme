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
        persona = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

        if response.is_a?(Net::HTTPSuccess)
          @event = Event.create_with(
            name: item['name'],
            description: item['description'],
            url: item['event_url'],
            features: {
              persona: {
                primary: {
                  name: persona['classification']['primary']['name'],
                  score: persona['classification']['primary']['score']
                },
                secondary: {
                  name: persona['classification']['secondary']['name'],
                  score: persona['classification']['secondary']['score']
                }
              }
            }
          ).find_or_create_by(url: item['event_url'])
        else
          @event = Event.create_with(
            name: item['name'],
            description: item['description'],
            url: item['event_url']
          ).find_or_create_by(url: item['event_url'])
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
          url: item['organizer_url']
        }).find_or_create_by(name: organizer)

        @event.organizers << @organizer unless @event.organizers.include?(@organizer)
        puts organizer.inspect
      end




      puts "Criar categoria ****************************************"


      item['categories'].try(:each) do |category|
        @category = Category.create_with({
          name: category
        }).find_or_create_by(name: category)

        @event.categories << @category unless @event.categories.include?(@category)
        puts @category.inspect
      end




      puts "Criar dia no calendário ****************************************"

      item['datetimes'].try(:each) do |datetime|
        @day_time = Calendar.create_with({
          day_time: datetime
        }).find_or_create_by(day_time: datetime)

        @event.calendars << @day_time unless @event.calendars.include?(@day_time)
        puts @day_time.inspect
      end

    end

  end

end
