class AddSwipableToUser < ActiveRecord::Migration[5.2]
	def change
		enable_extension "btree_gin"
		add_column :users, :swipable, :jsonb, null: false, default: {
				events: {
          last_view_at: nil,
          finished_at: nil,
          hidden_at: nil,
          active: true
				},
        movies: {
          last_view_at: nil,
          finished_at: nil,
          hidden_at: nil,
          active: true
				}
		}
		add_index :users, :swipable, using: :gin
		add_index :users, "(swipable -> 'events')", using: :gin, name: 'index_users_on_swipable_events'
    add_index :users, "(swipable -> 'movies')", using: :gin, name: 'index_users_on_swipable_movies'
	end
end
