class CreateFollows < ActiveRecord::Migration[6.0]
	def change
		create_table :follows do |t|
			t.integer :user_id, index: true
			t.integer :following_id, index: true
			t.string :following_type
			t.timestamps
		end
	end
end
