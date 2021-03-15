namespace :populate do
    task categories: :environment do
        
        categories_data = [
            {
                name: 'adventure_activities',
                display_name: 'Aventura ou excursão'
            },
            {
                name: 'thrift_store',
                display_name: 'Brechó ou Bazar'
            },
            {
                name: 'cinema',
                display_name: 'Cinema'
            },
            {
                name: 'sports_competition',
                display_name: 'Competição esportiva'
            },
            {
                name: 'academic_themes_course',
                display_name: 'Curso de tema acadêmico'
            },
            {
                name: 'dance_course',
                display_name: 'Curso de dança'
            },
            {
                name: 'wellness_course',
                display_name: 'Curso de bem-estar'
            },
            {
                name: 'business_course',
                display_name: 'Curso de negócios'
            },
            {
                name: 'art_course',
                display_name: 'Curso de arte'
            },
            {
                name: 'kitchen_course',
                display_name: 'Curso de culinária'
            },
            {
                name: 'music_course',
                display_name: 'Curso de música'
            },
            {
                name: 'dance_show',
                display_name: 'Espetáculo de dança'
            },
            {
                name: 'sport',
                display_name: 'Prática esportiva'
            },
            {
                name: 'exhibition',
                display_name: 'Exibição'
            },
            {
                name: 'gastronomic_experience',
                display_name: 'Experiência gastronômica'
            },
            {
                name: 'party',
                display_name: 'Festa'
            },
            {
                name: 'traditional_party',
                display_name: 'Festa tradicional'
            },
            {
                name: 'music_festival',
                display_name: 'Festival de música'
            },
            {
                name: 'arts_festival',
                display_name: 'Festival de artes'
            },
            {
                name: 'food_fair',
                display_name: 'Feira de comida'
            },
            {
                name: 'trade_fair',
                display_name: 'Feira de negócios'
            },
            {
                name: 'fashion_fair',
                display_name: 'Feira de moda'
            },
            {
                name: 'street_fair',
                display_name: 'Feira de rua'
            },
            {
                name: 'forum_or_seminar',
                display_name: 'Forum ou seminários'
            },
            {
                name: 'hackaton',
                display_name: 'Hackaton'
            },
            {
                name: 'meetup',
                display_name: 'Meetup'
            },
            {
                name: 'outlier',
                display_name: 'Outlier'
            },
            {
                name: 'talk',
                display_name: 'Palestra'
            },
            {
                name: 'protest',
                display_name: 'Protesto ou Causa'
            },
            {
                name: 'soiree',
                display_name: 'Sarau e Literatura'
            },
            {
                name: 'poetry_slam',
                display_name: 'Slam'
            },
            {
                name: 'show',
                display_name: 'Show'
            },
            {
                name: 'theatrical_show',
                display_name: 'Teatro e espetáculos'
            }
        ]
    
        categories_data.each do |category_data|
            category = Category.create(details: {
                name:         category_data[:name],
                display_name: category_data[:display_name]
            })
            
            puts "Categoria #{category.details['display_name']} criada".green
        end
    
    end
end