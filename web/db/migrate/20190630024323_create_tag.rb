class CreateTag < ActiveRecord::Migration[5.2]
	def change
		create_table :tags do |t|
			t.jsonb :details, null: false, default: {
					name: nil,
					type: nil
			}

			t.timestamps
		end

		add_index :tags, :details, using: :gin
	end
end
