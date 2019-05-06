class AddTasteToUsers < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    add_column :users, :taste, :jsonb, null: false, default: {
      events: {
        saved: [],
        liked: [],
        viewed: [],
        disliked: [],
        total_saves: 0,
        total_likes: 0,
        total_views: 0,
        total_dislikes: 0
      }
    }
    add_index  :users, :taste, using: :gin
  end
end
