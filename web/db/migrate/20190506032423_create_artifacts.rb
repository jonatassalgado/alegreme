class CreateArtifacts < ActiveRecord::Migration[5.2]
  def change
    create_table :artifacts do |t|
      t.jsonb :details, null: false, default: {
        name: nil,
        type: nil
      }
      t.jsonb :data, null: false, default: {}
      t.timestamps
    end
    add_index :artifacts, :details, using: :gin
    add_index :artifacts, :data, using: :gin
  end
end
