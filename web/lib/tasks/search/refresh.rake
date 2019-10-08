namespace :search do
	desc 'Atualiza índices para o sistema de busca serachkick'
	task refresh: :environment do
		Event.reindex
	end
end