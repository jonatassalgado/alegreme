require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

require_relative '../../geographic.rb'
require_relative '../../../config/initializers/shrine.rb'
require_relative '../../../app/uploaders/event_image_uploader'

module DeletedEventsRake

	def read_file
		files              = Dir['/var/www/scrapy/data/scraped/*']
		@current_file_name = (files.select { |file| file[/deleted-events-\d{8}-\d{6}\.jsonl$/] }).max

		if @current_file_name.nil?
			puts "Não foi encontrado nenhum arquivo na pasta /scraped".white
			abort
		end

		puts "Lendo arquivo JSON #{@current_file_name} da pasta /scraped".white

		@current_file = File.read(@current_file_name)
	end

	def remove_event(item)
		if item['deleted'] == 'true'
			Event.destroy_by("(details ->> 'source_url') = ?", item['source_url'])
			puts "Evento: #{item['source_url']} - Evento deletado".yellow
		end
	end

	def create_artifact
		timestr  = DateTime.now.strftime("%Y%m%d-%H%M%S")
		artifact = Artifact.create(
			details: {
				name: @current_file_name,
				type: 'scraped'
			}
		)

		artifact.file.attach(io: File.open("#{@current_file_name}"), filename: "deleted-events-#{timestr}.jsonl", content_type: "application/json")
	end
end

namespace :remove do
	desc 'Remove deleted events scraped from facebook'
	task deleted_events: :environment do

		include DeletedEventsRake

		puts "Task remove:deleted_events iniciada em #{DateTime.now}".white

		last_task_performed = Artifact.where(details: {
			name: "remove:deleted_events",
			type: "task"
		}).first

		# noinspection RubyArgCount
		@uploader               = EventImageUploader.new(:store)
		@events_create_counter  = 0
		@events_similar_counter = 0

		read_file

		if last_task_performed.try { |ltp| ltp.data['last_file_used'] == @current_file_name }
			puts "Task já realizada para o arquivo #{@current_file_name}".white
			abort
		end

		create_artifact

		begin
			data = JSONL.parse(@current_file)
		rescue JSON::ParserError => e
			puts "Erro ao ler arquivo JSON: #{e}".red
			return
		else
			puts "Arquivo JSON parseado".white
		end

		data.each do |item|
			remove_event(item)
		end

		if last_task_performed
			last_task_performed.touch
		else
			Artifact.create(
				details: {
					name: "remove:deleted_events",
					type: "task"
				},
				data:    {
					last_file_used: @current_file_name
				})
		end

		puts "Task remove:deleted_events finalizada em #{DateTime.now}}".white

		if @events_create_counter == 0
			puts "Nenhum evento criado para o arquivo #{@current_file_name}, abortando próximas tasks...".yellow
			abort
		end
	end
end
