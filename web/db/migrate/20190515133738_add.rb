class Add < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_column :events, :image_data, :jsonb, null: false, default: {}
    add_index  :events, :image_data, using: :gin
  end
end
