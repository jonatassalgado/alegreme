class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    create_table :places do |t|
      t.string :name
      t.string :address
      t.jsonb :geographic, :jsonb, null: false, default: {
        address: nil,
        latlon: [],
        neighborhood: nil,
        city: nil,
        cep: nil
      }
      t.timestamps
    end
    add_index  :places, :geographic, using: :gin
  end
end
