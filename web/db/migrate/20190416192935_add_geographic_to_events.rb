class AddGeographicToEvents < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_column :events, :geographic, :jsonb, null: false, default: {}
    add_index  :events, :geographic, using: :gin
  end
end
