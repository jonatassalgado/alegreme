class CreateTheme < ActiveRecord::Migration[6.0]
  def change
    create_table :themes do |t|
      t.string :name
      t.string :display_name
      t.string :slug
      t.text :description
      t.timestamps
    end
    add_reference :categories, :theme, foreign_key: true
  end
end
