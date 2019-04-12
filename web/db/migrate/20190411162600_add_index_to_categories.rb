class AddIndexToCategories < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_index  :events, :categories, using: :gin
  end
end
