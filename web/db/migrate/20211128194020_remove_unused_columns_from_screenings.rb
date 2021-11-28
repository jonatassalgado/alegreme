class RemoveUnusedColumnsFromScreenings < ActiveRecord::Migration[6.0]
	def change
		remove_columns :screenings, :movie_id, :cinema_id, :day
	end
end
