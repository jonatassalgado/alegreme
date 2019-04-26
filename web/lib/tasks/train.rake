namespace :ml do

  require 'json'
  require 'open-uri'
  require 'net/http'

  task train: :environment do


    files = Dir['../ml/*']
    last_file = (files.select{ |file| file[/svm-classification-events-\d{8}-\d{6}\.csv$/] }).max

    csv = CSV.read('../ml/' + last_file)
    events = Event.where("(personas -> 'primary' ->> 'score')::numeric >= 0.90 OR (categories -> 'primary' ->> 'score')::numeric >= 0.90").uniq

    events.each do |event|
      item = csv.find { |row| row[7] == event.source_url }
      if item
        item[8] = (event.personas['outlier'] == 'true' || event.personas['primary']['score'].to_f < 0.90) ? nil : event.personas['primary']['name']
        item[9] = (event.categories['outlier'] == 'true' || event.categories['primary']['score'].to_f < 0.90) ? nil : event.categories['primary']['name']
        item[10] = event.geographic['neighborhood']
      else
        csv << [
                event.name,
                event.geographic['address'],
                event.datetimes,
                event.try(:place).try(:name),
                event.organizers.pluck(:name),
                event.description,
                nil,
                event.source_url,
                (event.personas['outlier'] == 'true' || event.personas['primary']['score'].to_f < 0.90) ? nil : event.personas['primary']['name'],
                (event.categories['outlier'] == 'true' || event.categories['primary']['score'].to_f < 0.90) ? nil : event.categories['primary']['name'],
                event.geographic['neighborhood'],
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
