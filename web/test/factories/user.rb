FactoryBot.define do
	factory :user do
		sequence :email do |n|
			"person#{n}@example.com"
		end
		password { "password"}
		password_confirmation { "password" }
		features {
			{
					'psychographic': {
							'personas': {
									'primary':    {
											'name':  'hipster',
											'score': '1'
									},
									'secondary':  {
											'name':  'praieiro',
											'score': '1'
									},
									'tertiary':   {
											'name':  'underground',
											'score': '1'
									},
									'quartenary': {
											'name':  'cult',
											'score': '1'
									},
									'assortment': {
											finished: true
									}
							}
					}
			}
		}
		taste {
			{
					'events': {
							'saved':          [],
							'liked':          [],
							'viewed':         [],
							'disliked':       [],
							'total_saves':    0,
							'total_likes':    0,
							'total_views':    0,
							'total_dislikes': 0
					}
			}
		}
		admin { false }

	end
end
