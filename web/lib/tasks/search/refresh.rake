namespace :search do
	desc 'Atualiza índices para o sistema de busca serachkick'
	task refresh: :environment do
		if ENV['RAILS_ENV'] == 'production'
			Event.reindex
		end
	end
end