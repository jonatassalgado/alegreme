class Category < ApplicationRecord
	has_and_belongs_to_many :events, touch: true

	CATEGORIES = {
		'adventure_activities'   => {
			'display_name' => 'Aventura ou excursão',
			'url'          => 'aventura-ou-excursao'
		},
		'thrift_store'           => {
			'display_name' => 'Brechó ou Bazar',
			'url'          => 'brecho-ou-bazar'
		},
		'cinema'                 => {
			'display_name' => 'Cinema',
			'url'          => 'cinema'
		},
		'sports_competition'     => {
			'display_name' => 'Competição esportiva',
			'url'          => 'competicao-esportiva'
		},
		'academic_themes_course' => {
			'display_name' => 'Curso de tema acadêmico',
			'url'          => 'curso-de-tema-academico'
		},
		'dance_course'           => {
			'display_name' => 'Curso de dança',
			'url'          => 'curso-de-danca'
		},
		'wellness_course'        => {
			'display_name' => 'Curso de bem-estar',
			'url'          => 'curso-de-bem-setar'
		},
		'business_course'        => {
			'display_name' => 'Curso de negócios',
			'url'          => 'curso-de-negocios'
		},
		'art_course'             => {
			'display_name' => 'Curso de arte',
			'url'          => 'curso-de-arte'
		},
		'kitchen_course'         => {
			'display_name' => 'Curso de culinária',
			'url'          => 'curso-de-culinaria'
		},
		'music_course'           => {
			'display_name' => 'Curso de música',
			'url'          => 'curso-de-musica'
		},
		'dance_show'             => {
			'display_name' => 'Espetáculo de dança',
			'url'          => 'espetaculo-de-danca'
		},
		'sport'                  => {
			'display_name' => 'Prática esportiva',
			'url'          => 'pratica-esportiva'
		},
		'exhibition'             => {
			'display_name' => 'Exposição',
			'url'          => 'exposicao'
		},
		'gastronomic_experience' => {
			'display_name' => 'Experiência gastronômica',
			'url'          => 'experiencia-gastronomica'
		},
		'party'                  => {
			'display_name' => 'Festa',
			'url'          => 'festa'
		},
		'traditional_party'      => {
			'display_name' => 'Festa tradicional',
			'url'          => 'festa-tradicional'
		},
		'music_festival'         => {
			'display_name' => 'Festival de música',
			'url'          => 'festival-de-musica'
		},
		'arts_festival'          => {
			'display_name' => 'Festival de artes',
			'url'          => 'festival-de-artes'
		},
		'food_fair'              => {
			'display_name' => 'Feira de comida',
			'url'          => 'feira-de-comida'
		},
		'trade_fair'             => {
			'display_name' => 'Feira de negócios',
			'url'          => 'feira-de-negocios'
		},
		'fashion_fair'           => {
			'display_name' => 'Feira de moda',
			'url'          => 'feira-de-moda'
		},
		'street_fair'            => {
			'display_name' => 'Feira de rua',
			'url'          => 'feira-de-rua'
		},
		'forum_or_seminar'       => {
			'display_name' => 'Forum ou seminários',
			'url'          => 'forum-ou-seminario'
		},
		'hackaton'               => {
			'display_name' => 'Hackaton',
			'url'          => 'hackaton'
		},
		'meetup'                 => {
			'display_name' => 'Meetup',
			'url'          => 'meetup'
		},
		'outlier'                => {
			'display_name' => 'Outlier',
			'url'          => 'outlier'
		},
		'talk'                   => {
			'display_name' => 'Palestra',
			'url'          => 'palestra'
		},
		'protest'                => {
			'display_name' => 'Protesto ou Causa',
			'url'          => 'protesto-ou-causa'
		},
		'soiree'                 => {
			'display_name' => 'Sarau e Literatura',
			'url'          => 'sarau-e-literatura'
		},
		'poetry_slam'            => {
			'display_name' => 'Slam',
			'url'          => 'slam'
		},
		'show'                   => {
			'display_name' => 'Show',
			'url'          => 'show'
		},
		'theatrical_show'        => {
			'display_name' => 'Teatro ou espetáculo',
			'url'          => 'teatro-ou-espetaculo'
		}
	}.freeze

	def details_name
		details['name']
	end

	def details_display_name
		details['display_name']
	end

	def details_url
		details['url']
	end
end
