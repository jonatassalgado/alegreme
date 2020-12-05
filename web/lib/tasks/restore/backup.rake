namespace :restore do

	require 'json'
	require 'open-uri'
	require 'colorize'

	desc "Exporta os evetnos para CSV de treinamento"
	task backup: :environment do

		if ENV['IS_DOCKER'] == 'true'
			files = Dir['/var/www/alegreme/db/backups/production/*']
		else
			files = Dir['../web/db/backups/production/*']
		end
		last_file = (files.select { |file| file[/\d{14}_production.sql$/] }).max
    ENV['pattern'] = last_file.slice(-29, 14)

		puts "Restaurando o arquivo #{last_file}".blue


    Rake::Task['db:restore'].invoke

	end
end
