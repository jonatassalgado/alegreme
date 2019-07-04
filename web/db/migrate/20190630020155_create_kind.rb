class CreateKind < ActiveRecord::Migration[5.2]
	def change
		create_table :kinds do |t|
			t.jsonb :details, null: false, default: {
					name:       nil,
					categories: []
			}

			t.timestamps
		end

		add_index :kinds, :details, using: :gin
	end
end
