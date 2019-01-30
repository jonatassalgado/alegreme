namespace :scrapy do

  require 'json'
  require 'open-uri'

  task facebook: :environment do
    puts "Parsear JSON ****************************************"

    file = File.read('../events.json')
    data = JSON.parse(file)

    puts data


    data.each do |item|

      puts "Criar lugar ****************************************"

      @place = Place.create_with({
        name: item['place'],
        address: item['address']
        }).find_or_create_by(name: item['place'])

        puts @place.inspect



      puts "Criar Evento ****************************************"

      @event = Event.create_with(
        name: item['name'],
        description: item['description'],
        url: item['event_url']
      ).find_or_create_by(url: item['event_url'])

      cover = open(item['cover_url'])
      @event.cover.attach(io: cover, filename: "event#{@event.id}.jpg", content_type: "image/jpg")

      @place.events << @event unless @place.events.include?(@event)
      puts @event.inspect

 

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
