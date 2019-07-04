class CreateOrganizers < ActiveRecord::Migration[5.2]
	def change
		create_table :organizers do |t|
			t.jsonb :details, null: false, default: {
					name:       nil,
					source_url: nil
			}

			t.timestamps
		end

		add_index :organizers, :details, using: :gin
	end
end
