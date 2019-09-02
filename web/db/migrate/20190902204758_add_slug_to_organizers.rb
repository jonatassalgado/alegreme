class AddSlugToOrganizers < ActiveRecord::Migration[5.2]
  def change
    add_column :organizers, :slug, :string
    add_index :organizers, :slug, unique: true
  end
end
