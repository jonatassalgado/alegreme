class CreateScreeningsAndCinemas < ActiveRecord::Migration[6.0]
	def change
		create_table :cinemas do |t|
			t.string :name
			t.string :display_name
			t.string :address
			t.string :slug
			t.index :slug, unique: true
			t.timestamps
		end
		create_table :screenings do |t|
			t.date :day
			t.text :times, array: true, default: []
			t.string :language
			t.string :screen_type
			t.belongs_to :cinema, index: true, foreign_key: true
			t.belongs_to :movies, index: true, foreign_key: true
			t.timestamps
		end
	end
end
