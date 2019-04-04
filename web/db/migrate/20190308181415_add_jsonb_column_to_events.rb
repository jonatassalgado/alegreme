class AddJsonbColumnToEvents < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_index  :events, :personas, using: :gin
    add_index  :events, :ocurrences, using: :gin
  end
end
