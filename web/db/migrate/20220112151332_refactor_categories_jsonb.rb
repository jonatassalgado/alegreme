class RefactorCategoriesJsonb < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :name, :string
    add_column :categories, :display_name, :string
    add_column :categories, :url, :string
    add_column :categories, :emoji, :string
  end
end
