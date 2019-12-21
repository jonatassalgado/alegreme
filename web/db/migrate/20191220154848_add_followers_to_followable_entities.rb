class AddFollowersToFollowableEntities < ActiveRecord::Migration[5.2]
	def change
		enable_extension "btree_gin"
		add_column :users, :followers, :jsonb, null: false, default: {
				users:                 [],
				users_total_followers: 0
		}
		add_column :organizers, :followers, :jsonb, null: false, default: {
				users:                 [],
				users_total_followers: 0
		}
		add_column :places, :followers, :jsonb, null: false, default: {
				users:                 [],
				users_total_followers: 0
		}
		add_column :categories, :followers, :jsonb, null: false, default: {
				users:                 [],
				users_total_followers: 0
		}
		add_column :kinds, :followers, :jsonb, null: false, default: {
				users:                 [],
				users_total_followers: 0
		}
		add_column :tags, :followers, :jsonb, null: false, default: {
				users:                 [],
				users_total_followers: 0
		}
		add_index :users, :followers, using: :gin
		add_index :organizers, :followers, using: :gin
		add_index :places, :followers, using: :gin
		add_index :categories, :followers, using: :gin
		add_index :kinds, :followers, using: :gin
		add_index :tags, :followers, using: :gin
	end
end
