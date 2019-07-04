class AddFeaturesToUser < ActiveRecord::Migration[5.2]
	def change
		enable_extension "btree_gin"
		add_column :users, :features, :jsonb, null: false, default: {
				psychographic: {
						personas:   {
								primary:    {
										name:  nil,
										score: nil,
								},
								secondary:  {
										name:  nil,
										score: nil,
								},
								tertiary:   {
										name:  nil,
										score: nil,
								},
								quartenary: {
										name:  nil,
										score: nil,
								},
								assortment: {
										finished:    nil,
										finished_at: nil,
								}
						},
						activities: {
								names:      [],
								assortment: {
										finished:    nil,
										finished_at: nil,
								}
						}
				},
				demographic:   {
						name:            nil,
						age:             nil,
						profession:      nil,
						gender:          nil,
						university:      nil,
						education_level: nil,
						income_level:    nil,
						marital_status:  nil,
						with_kids:       nil,
						assortment:      {
								finished:    nil,
								finished_at: nil,
						}
				},
				geographic:    {
						home:       {
								address:      nil,
								latlon:       [],
								neighborhood: nil,
								city:         nil,
								cep:          nil
						},
						current:    {
								address:      nil,
								latlon:       [],
								neighborhood: nil,
								city:         nil,
								cep:          nil,
								timestamp:    nil
						},
						assortment: {
								finished:    nil,
								finished_at: nil,
						}
				}
		}
		add_column :users, :taste, :jsonb, null: false, default: {
				events: {
						saved:          [],
						liked:          [],
						viewed:         [],
						disliked:       [],
						total_saves:    0,
						total_likes:    0,
						total_views:    0,
						total_dislikes: 0
				}
		}
		add_column :users, :following, :jsonb, null: false, default: {
				places:     [],
				organizers: [],
				categories: [],
				kinds:      [],
				tags:       [],
				users:      []
		}
		add_column :users, :admin, :boolean, default: false
		add_index :users, :features, using: :gin
		add_index :users, "(features -> 'psychographic')", using: :gin, name: 'index_users_on_features_psychographic'
		add_index :users, "(features -> 'psychographic' -> 'personas')", using: :gin, name: 'index_users_on_features_psychographic_personas'
		add_index :users, "(features -> 'psychographic' -> 'personas' -> 'primary')", using: :gin, name: 'index_users_on_features_psychographic_personas_primary'
		add_index :users, "(features -> 'psychographic' -> 'personas' -> 'secondary')", using: :gin, name: 'index_users_on_features_psychographic_personas_secondary'
		add_index :users, "(features -> 'psychographic' -> 'personas' -> 'tertiary')", using: :gin, name: 'index_users_on_features_psychographic_personas_tertiary'
		add_index :users, "(features -> 'psychographic' -> 'personas' -> 'quartenary')", using: :gin, name: 'index_users_on_features_psychographic_personas_quartenary'
		add_index :users, "(features -> 'psychographic' -> 'activities')", using: :gin, name: 'index_users_on_features_psychographic_activities'
		add_index :users, "(features -> 'demographic')", using: :gin, name: 'index_users_on_features_demographic'
		add_index :users, "(features -> 'geographic')", using: :gin, name: 'index_users_on_features_geographic'
		add_index :users, :taste, using: :gin
	end
end
