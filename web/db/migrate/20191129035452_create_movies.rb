class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    enable_extension "btree_gin"
    create_table :movies do |t|
      t.jsonb :details, null: false, default: {
					name:        nil,
          genre:       nil,
					description: nil,
          cover:       nil,
          trailler:    nil
			}
      t.jsonb :dates, null: false, default: [
        {
          "date": nil,
          "places": [
            {
              "name": nil,
              "address": nil,
              "languages": [
                {
                  "name": nil,
                  "screen_type": nil,
                  "times": []
                }
              ]
            }
          ]
        }
      ]
      t.timestamps
    end
    add_index :movies, :details, using: :gin
    add_index :movies, :dates, using: :gin
  end
end
