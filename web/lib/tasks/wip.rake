
require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

task wip: :environment do
	Event.all.each_with_index do |e, index|
		puts "#{index} - #{e.name}"
		e.ml_data = {}
		e.save
	end
end
