class AddImageDataToOrganizers < ActiveRecord::Migration[6.0]
  def change
    add_column :organizers, :image_data, :text
  end
end
