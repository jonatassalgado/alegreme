class AddStatusToMovies < ActiveRecord::Migration[6.0]
	def change
		add_column :movies, :status, :integer, default: :pending
		Movie.update_all(status: :active)
	end
end
