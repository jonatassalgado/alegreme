class AddImageDataToPlaces < ActiveRecord::Migration[6.0]
  def change
    add_column :places, :image_data, :text
  end
end
