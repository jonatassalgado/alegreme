class RemoveOldFollows < ActiveRecord::Migration[6.0]
	def change
		drop_table :follows
		remove_column :users, :followers
		remove_column :organizers, :followers
		remove_column :places, :followers
		remove_column :categories, :followers
		remove_column :kinds, :followers
		remove_column :tags, :followers
	end
end
