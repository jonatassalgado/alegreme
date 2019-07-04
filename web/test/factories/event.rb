FactoryBot.define do
	factory :event do
		sequence :id do |n|
			n
		end
		ocurrences {
			{
					'dates': [(Date.current + 1).to_s]
			}
		}
		theme {
			{
					'name':    '',
					'score':   '',
					'outlier': ''
			}
		}
		geographic {
			{
					'cep':          '90040 - 480',
					'city':         'Porto Alegre',
					'latlon':       {
							'address': 'Avenida João Pessoa, 90040 - 480 Porto Alegre'
					},
					'neighborhood': ''
			}
		}
		details {
			{
					'name':        'Serenata Iluminada na Virada Sustentável',
					'prices':      [],
					'source_url':  'https : // www.facebook.com / events / 373799036764008',
					'description': '<span>A Serenata Iluminada é um movimento de pessoas que amam Porto
      Alegre e querem o melhor para a nossa cidade! Por isso, em abril estaremos mais
      uma vez juntos com a Virada Sustentável Porto Alegre 2019 para realizar uma'
			}
		}
		entries {
			{
					'liked_by':       [],
					'saved_by':       [],
					'viewed_by':      [],
					'disliked_by':    [],
					'total_likes':    0,
					'total_saves':    0,
					'total_views':    0,
					'total_dislikes': 0,
			}
		}
		ml_data {
			{
					'personas':   {
							'outlier':   false,
							'primary':   {
									'name':  'hipster',
									'score': '0.996777',
							},
							'secondary': {
									'name':  'zeen',
									'score': '0.003223',
							}

					},
					'categories': {

							'outlier':   false,
							'primary':   {
									'name':  'festa',
									'score': '0.999241',
							},
							'secondary': {
									'name':  'meetup',
									'score': '0.000759',
							}

					},
					'tags':       {
							'things':     [],
							'features':   [],
							'activities': []
					},
					'kinds':      ['acadêmico']
			}

		}
		# factory :event_with_place do
		place
		# end
		factory :event_with_organizers do
			transient do
				organizers_count { 5 }
			end
			after(:create) do |event, evaluator|
				create_list(:organizer, evaluator.organizers_count, events: [event])
			end
		end
	end
end
