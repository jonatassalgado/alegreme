namespace :ml do

  require 'json'
  require 'open-uri'
  require 'net/http'

  task train: :environment do


    files = Dir['../ml/*']
    last_file = (files.select{ |file| file[/svm-classification-events-\d{8}-\d{6}\.csv$/] }).max

    csv = CSV.read('../ml/' + last_file)
    events = Event.where("(personas -> 'primary' ->> 'score')::numeric >= 0.90").uniq

    events.each do |event|
      item = csv.find { |row| row[4] == event.source_url }
      if item
        item[8] = event.personas['primary']['name']
      else
        csv << [
                event.name,
                event.try(:place).try(:address),
                event.datetimes,
                event.try(:place).try(:name),
                event.organizers.pluck(:name),
                event.description,
                nil,
                event.source_url,
                event.personas['primary']['name'],
                nil,
                nil,
                nil]
      end

    end


    timestr = DateTime.now.strftime("%Y%m%d-%H%M%S")
    CSV.open('../ml/svm-classification-events-' + timestr + '.csv', 'wb') do |row|
      csv.each do |item|
        row << item
      end
    end


  end

end
