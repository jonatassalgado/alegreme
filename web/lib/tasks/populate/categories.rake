namespace :populate do
    task categories: :environment do
        
        categories_data = [
            {
                name: 'adventure_activities',
                display_name: 'Aventura ou excursão',
                url: 'aventura-ou-excursao'
            },
            {
                name: 'thrift_store',
                display_name: 'Brechó ou Bazar',
                url: 'brecho-ou-bazar'
            },
            {
                name: 'cinema',
                display_name: 'Cinema',
                url: 'cinema'
            },
            {
                name: 'sports_competition',
                display_name: 'Competição esportiva',
                url: 'competicao-esportiva'
            },
            {
                name: 'academic_themes_course',
                display_name: 'Curso de tema acadêmico',
                url: 'curso-de-tema-academico'
            },
            {
                name: 'dance_course',
                display_name: 'Curso de dança',
                url: 'curso-de-danca'
            },
            {
                name: 'wellness_course',
                display_name: 'Curso de bem-estar',
                url: 'curso-de-bem-setar'
            },
            {
                name: 'business_course',
                display_name: 'Curso de negócios',
                url: 'curso-de-negocios'
            },
            {
                name: 'art_course',
                display_name: 'Curso de arte',
                url: 'curso-de-arte'
            },
            {
                name: 'kitchen_course',
                display_name: 'Curso de culinária',
                url: 'curso-de-culinaria'
            },
            {
                name: 'music_course',
                display_name: 'Curso de música',
                url: 'curso-de-musica'
            },
            {
                name: 'dance_show',
                display_name: 'Espetáculo de dança',
                url: 'espetaculo-de-danca'
            },
            {
                name: 'sport',
                display_name: 'Prática esportiva',
                url: 'pratica-esportiva'
            },
            {
                name: 'exhibition',
                display_name: 'Exposição',
                url: 'exposicao'
            },
            {
                name: 'gastronomic_experience',
                display_name: 'Experiência gastronômica',
                url: 'experiencia-gastronomica'
            },
            {
                name: 'party',
                display_name: 'Festa',
                url: 'festa'
            },
            {
                name: 'traditional_party',
                display_name: 'Festa tradicional',
                url: 'festa-tradicional'
            },
            {
                name: 'music_festival',
                display_name: 'Festival de música',
                url: 'festival-de-musica'
            },
            {
                name: 'arts_festival',
                display_name: 'Festival de artes',
                url: 'festival-de-artes'
            },
            {
                name: 'food_fair',
                display_name: 'Feira de comida',
                url: 'feira-de-comida'
            },
            {
                name: 'trade_fair',
                display_name: 'Feira de negócios',
                url: 'feira-de-negocios'
            },
            {
                name: 'fashion_fair',
                display_name: 'Feira de moda',
                url: 'feira-de-moda'
            },
            {
                name: 'street_fair',
                display_name: 'Feira de rua',
                url: 'feira-de-rua'
            },
            {
                name: 'forum_or_seminar',
                display_name: 'Forum ou seminários',
                url: 'forum-ou-seminario'
            },
            {
                name: 'hackaton',
                display_name: 'Hackaton',
                url: 'hackaton'
            },
            {
                name: 'meetup',
                display_name: 'Meetup',
                url: 'meetup'
            },
            {
                name: 'outlier',
                display_name: 'Outlier',
                url: 'outlier'
            },
            {
                name: 'talk',
                display_name: 'Palestra',
                url: 'palestra'
            },
            {
                name: 'protest',
                display_name: 'Protesto ou Causa',
                url: 'protesto-ou-causa'
            },
            {
                name: 'soiree',
                display_name: 'Sarau e Literatura',
                url: 'sarau-e-literatura'
            },
            {
                name: 'poetry_slam',
                display_name: 'Slam',
                url: 'slam'
            },
            {
                name: 'show',
                display_name: 'Show',
                url: 'show'
            },
            {
                name: 'theatrical_show',
                display_name: 'Teatro ou espetáculo',
                url: 'teatro-ou-espetaculo'
            }
        ]
    
        categories_data.each do |category_data|
            category = Category.create(details: {
                name:         category_data[:name],
                display_name: category_data[:display_name],
                url:          category_data[:url]
            })
            
            puts "Categoria #{category.details['display_name']} criada".green
        end
    
    end
end