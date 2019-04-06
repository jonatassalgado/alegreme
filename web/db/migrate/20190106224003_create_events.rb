class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.string :source_url
      t.jsonb :personas, null: false, default: '{}'
      t.jsonb :ocurrences, null: false, default: '{}'

      t.timestamps
    end
  end
end
