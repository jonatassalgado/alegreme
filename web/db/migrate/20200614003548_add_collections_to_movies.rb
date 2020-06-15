class AddCollectionsToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :collections, :jsonb, null: false, default: []
  end
end
