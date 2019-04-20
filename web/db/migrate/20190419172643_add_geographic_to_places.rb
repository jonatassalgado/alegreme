class AddGeographicToPlaces < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_column :places, :geographic, :jsonb, null: false, default: {}
    add_index  :places, :geographic, using: :gin
  end
end
