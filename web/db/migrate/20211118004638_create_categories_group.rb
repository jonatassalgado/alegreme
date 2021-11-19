class CreateCategoriesGroup < ActiveRecord::Migration[6.0]
  def change
    create_table :categories_groups do |t|
      t.string :name
      t.string :url
      t.string :display_name
      t.string :emoji
    end
    change_table :categories do |t|
      t.belongs_to :categories_group
    end
  end
end
