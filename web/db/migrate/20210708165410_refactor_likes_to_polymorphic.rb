class RefactorLikesToPolymorphic < ActiveRecord::Migration[6.0]
	def change
		rename_index :likes, 'index_likes_on_event_id', 'index_likes_on_likeable_id'
		rename_column :likes, :event_id, :likeable_id
		add_column :likes, :likeable_type, :string
		Like.update_all(likeable_type: 'Event')
	end
end
