FactoryBot.define do
	factory :place do
		details {
			{
					'name': 'Parque da Redenção'
			}
		}
		geographic {
			{
					'address':      nil,
					'latlon':       [],
					'neighborhood': nil,
					'city':         nil,
					'cep':          nil
			}
		}
	end
end
