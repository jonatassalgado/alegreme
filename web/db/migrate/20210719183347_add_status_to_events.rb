class AddStatusToEvents < ActiveRecord::Migration[6.0]
	def change
		add_column :events, :status, :integer, default: :pending
		Event.update_all(status: :active)
	end
end
