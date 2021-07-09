class RefactorMoviesColumnsFromJsonb < ActiveRecord::Migration[6.0]
  def change
    remove_index :movies, :details
    remove_columns :movies, :entries, :collections, :details
    add_column :movies, :cover, :string
    add_column :movies, :title, :string
    add_column :movies, :genres, :text, array: true, default: []
    add_column :movies, :trailer, :string
    add_column :movies, :rating, :numeric
    add_column :movies, :description, :text
    add_column :movies, :adult, :boolean, default: false
  end
end
