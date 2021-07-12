class AddGoogleIdToCinemas < ActiveRecord::Migration[6.0]
  def change
    add_column :cinemas, :google_id, :string
  end
end
