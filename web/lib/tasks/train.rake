namespace :ml do

  require 'json'
  require 'open-uri'
  require 'net/http'

  task train: :environment do

    if ENV['IS_DOCKER'] == 'true'
      files = Dir['/var/www/scrapy/data/classified/*']
    else
      files = Dir['../scrapy/classified/*']
    end
    last_file = (files.select{ |file| file[/svm-classification-events-\d{8}-\d{6}\.csv$/] }).max
    csv = CSV.read(last_file)

    events = Event.where("(personas -> 'primary' ->> 'score')::numeric >= 0.90 OR (categories -> 'primary' ->> 'score')::numeric >= 0.90").uniq

    events.each do |event|
      item = csv.find { |row| row[7] == event.details['source_url'] }
      if item
        item[8] = (event.personas['outlier'] == 'true' || event.personas['primary']['score'].to_f < 0.90) ? nil : event.personas['primary']['name']
        item[9] = (event.categories['outlier'] == 'true' || event.categories['primary']['score'].to_f < 0.90) ? nil : event.categories['primary']['name']
        item[10] = event.geographic['neighborhood']
      else
        csv << [
                event.details['name'],
                event.geographic['address'],
                event.datetimes,
                event.try(:place).details['name'],
                event.organizers.pluck(:name),
                event.details['description'],
                nil,
                event.details['source_url'],
                (event.personas['outlier'] == 'true' || event.personas['primary']['score'].to_f < 0.90) ? nil : event.personas['primary']['name'],
                (event.categories['outlier'] == 'true' || event.categories['primary']['score'].to_f < 0.90) ? nil : event.categories['primary']['name'],
                event.geographic['neighborhood'],
                nil]
      end

    end


    timestr = DateTime.now.strftime("%Y%m%d-%H%M%S")
    artifact = Artifact.create(name: "svm-classification-events-#{timestr}")
    
    if ENV['IS_DOCKER'] == 'true'
      CSV.open('/var/www/scrapy/data/classified/svm-classification-events-' + timestr + '.csv', 'wb') do |row|
        csv.each do |item|
          row << item
        end
      end
      artifact.file.attach(io: File.open("/var/www/scrapy/data/classified/svm-classification-events-#{timestr}.csv"), filename: "svm-classification-events-#{timestr}.csv", content_type: "text/csv")
    else
      CSV.open('../scrapy/classified/svm-classification-events-' + timestr + '.csv', 'wb') do |row|
        csv.each do |item|
          row << item
        end
      end
      artifact.file.attach(io: File.open("../scrapy/classified/svm-classification-events-#{timestr}.csv"), filename: "svm-classification-events-#{timestr}.csv", content_type: "text/csv")
    end
  
  end
end
