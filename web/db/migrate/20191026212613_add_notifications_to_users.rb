class AddNotificationsToUsers < ActiveRecord::Migration[5.2]
	def change
		enable_extension "btree_gin"
		add_column :users, :notifications, :jsonb, null: false, default: {
				devices: [],
				topics:  {
						all: {
								requested: nil,
								active:   nil
						}
				}
		}

		add_index :users, :notifications, using: :gin
		add_index :users, "(notifications ->> 'devices')", using: :gin, name: 'index_users_on_notifications_devices'
	end
end
