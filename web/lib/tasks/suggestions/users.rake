require 'colorize'

namespace :suggestions do
	desc 'Atualizar sugestões dos usuários'
	task users: :environment do

		users = User.where("(features -> 'demographic' -> 'beta' ->> 'activated')::boolean = true")

		users.each do |user|
			UpdateUserEventsSuggestionsJob.perform_later(user.id)
		end

		puts "Sugestões atualizadas de #{users.size} usuários".green
	end
end
