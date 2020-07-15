require 'net/http'
require 'openssl'
require 'uri'
require 'json'

task wip: :environment do


	locations = [
			{
					"icon"         => "https://utellyassets7.imgix.net/locations_icons/utelly/black_new/NetflixIVABR.png?w=92&auto=compress&app_version=5cb1e6a4-e86c-45a8-bd57-1fe10ea6e2ca_eww2020-07-15",
					"country"      => [
							"br"
					],
					"display_name" => "Netflix",
					"name"         => "NetflixIVABR",
					"id"           => "5d84d6e2d95dc7385f6a442f",
					"url"          => "https://www.netflix.com/title/80244088"
			}
	]

	ap locations

	movie            = Movie.new
	movie.streamings = locations
	movie.save


end
