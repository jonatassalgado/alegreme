class CreatePoster < ActiveRecord::Migration[6.0]
  def change
    enable_extension "btree_gin"
    create_table :posters do |t|
      t.jsonb :details, null: false, default: {
          shortcode:          nil,
          caption:            nil,
          taken_at_timestamp: nil,
          source_url:         nil
      }
      t.jsonb :owner, null: false, default: []
      t.jsonb :media, null: false, default: []
      t.jsonb :occurrences, null: false, default: {
        datetimes: []
      }
      t.jsonb :geographic, null: false, default: {
					address:      nil,
					latlon:       [],
					neighborhood: nil,
					city:         nil,
					cep:          nil
			}
      t.jsonb :ml_data, null: false, default: {
					cleanned: nil,
					stemmed:  nil,
					nouns:    [],
					verbs:    [],
					adjs:     []
			}
      t.timestamps
    end
    add_index :posters, :details, using: :gin
    add_index :posters, :owner, using: :gin
    add_index :posters, :media, using: :gin
    add_index :posters, :occurrences, using: :gin
    add_index :posters, :geographic, using: :gin
    add_index :posters, "(occurrences -> 'datetimes')", using: :gin, name: 'index_posters_on_occurrences_datetimes'
    add_index :posters, "(geographic -> 'address')", using: :gin, name: 'index_posters_on_geographic_address'
    add_index :posters, "(details -> 'shortcode')", using: :gin, name: 'index_posters_on_details_shortcode'
    add_index :posters, "(details -> 'source_url')", using: :gin, name: 'index_posters_on_details_source_url'
  end
end
