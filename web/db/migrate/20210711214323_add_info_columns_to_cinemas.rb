class AddInfoColumnsToCinemas < ActiveRecord::Migration[6.0]
  def change
    add_column :cinemas, :website, :string
    add_column :cinemas, :reference_place, :string
    add_column :cinemas, :lower_price, :numeric
    add_column :cinemas, :neighborhood, :string
    add_column :cinemas, :google_maps, :string
  end
end
