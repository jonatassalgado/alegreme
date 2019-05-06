class AddEntriesToEvent < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_column :events, :entries, :jsonb, null: false, default: {
      saved_by: [],
      liked_by: [],
      viewed_by: [],
      disliked_by: [],
      total_saves: 0,
      total_likes: 0,
      total_views: 0,
      total_dislikes: 0
    }
    add_index  :events, :entries, using: :gin
  end
end
