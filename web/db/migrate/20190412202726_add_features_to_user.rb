class AddFeaturesToUser < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_column :users, :features, :jsonb, null: false, default: {}
    add_index  :users, :features, using: :gin
  end
end
