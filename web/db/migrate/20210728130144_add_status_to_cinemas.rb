class AddStatusToCinemas < ActiveRecord::Migration[6.0]
  def change
    add_column :cinemas, :status, :integer, default: :pending
    Cinema.update_all(status: :active)
  end
end
