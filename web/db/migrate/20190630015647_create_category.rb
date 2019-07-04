class CreateCategory < ActiveRecord::Migration[5.2]
	def change
		create_table :categories do |t|
			t.jsonb :details, null: false, default: {
					name: nil
			}

			t.timestamps
		end

		add_index :categories, :details, using: :gin
	end
end
