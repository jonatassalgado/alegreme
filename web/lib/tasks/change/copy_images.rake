require 'colorize'
require 'open-uri'
require 'net/http'
require 'down'

require_relative '../../../config/initializers/shrine.rb'
require_relative '../../../app/uploaders/event_image_uploader'


namespace :digitalocean do
	desc 'Copy images from host storage to Digital Cloud space'
	task copy_images: :environment do
		# noinspection RubyArgCount
		@uploader               = EventImageUploader.new(:store)
		@events_create_counter  = 0
		@events_similar_counter = 0
		@events = Event.all
		@host = Rails.env == 'development' ? 'http://localhost:3000' : 'https://www.alegreme.com'

		@events.each do |event|

			next unless event.image

			file_name = "event-#{event.name.parameterize}"

			begin
				event_cover_file = Down.download("#{@host}/uploads/#{event.image[:original].id}")
			rescue Down::Error => e
				puts "#{event.name} - Erro no download da imagem (#{event.image[:original].id}) - #{e}".red
				return false
			else
				puts "#{event.name} - Download da imagem (#{event.image[:original].id}) - Sucesso".green
			end

			begin
				event.image = event_cover_file
				puts "#{event.name} - Upload de imagem".blue
			rescue
				puts "#{event.name} - Erro no upload da image #{e}".red
				return false
			end

			event.save!

			@events_create_counter += 1
			puts "#{event.name[0..60]} imagem copiada #{@events_create_counter}".green
		end
	end
end

