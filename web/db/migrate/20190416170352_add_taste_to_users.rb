class AddTasteToUsers < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_column :users, :taste, :jsonb, null: false, default: {}
    add_index  :users, :taste, using: :gin
  end
end
