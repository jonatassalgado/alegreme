class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    create_table :events do |t|
      t.string :name
      t.text :description
      t.string :source_url
      t.jsonb :personas, null: false, default: {
        primary: {
          name: nil,
          score: nil
        },
        secondary: {
          name: nil,
          score: nil
        },
        outlier: nil
      }
      t.jsonb :categories, null: false, default: {
        primary: {
          name: nil,
          score: nil
        },
        secondary: {
          name: nil,
          score: nil
        },
        outlier: nil
      }
      t.jsonb :geographic, null: false, default: {
        address: nil,
        latlon: [],
        neighborhood: nil,
        city: nil,
        cep: nil
      }
      
      t.jsonb :ocurrences, null: false, default: {
        dates: []
      }
      t.jsonb :entries, :jsonb, null: false, default: {
        saved_by: [],
        liked_by: [],
        viewed_by: [],
        disliked_by: [],
        total_saves: 0,
        total_likes: 0,
        total_views: 0,
        total_dislikes: 0
      }
      t.jsonb :image_data, :jsonb, null: false, default: {}
      t.timestamps
    end
    add_index  :events, :personas, using: :gin
    add_index  :events, :categories, using: :gin
    add_index  :events, :geographic, using: :gin
    add_index  :events, :ocurrences, using: :gin
    add_index  :events, :entries, using: :gin
    add_index  :events, :image_data, using: :gin
  end
end
