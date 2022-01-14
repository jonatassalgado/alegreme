namespace :change do
	desc 'Converter jsonb to columns'
	task convert_details_jsonb: :environment do
		categories = Category.all
		counter    = 0

		categories.find_each do |category|
			category.name         = category.details['name']
			category.display_name = category.details['display_name']
			category.url          = category.details['url']
			category.emoji        = category.details['emoji']

			if category.save!
				counter += 1
				puts "#{counter}: (#{category.id}) Categoria atualizada -> #{category.display_name}"
			end
		end
	end
end