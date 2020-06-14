class AddTypeAndUpdateDefaultsToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :type, :string
    add_column :movies, :streamings, :jsonb, null: false, default: []
    change_column_default :movies, :details, from: {
                                              name:        nil,
                                              genre:       nil,
                                              description: nil,
                                              cover:       nil,
                                              trailler:    nil
                                            },
                                             to: {
                                               original_title: nil,
                                               title:          nil,
                                               genres:         [],
                                               description:    nil,
                                               cover:          nil,
                                               trailler:       nil,
                                               popularity:     nil,
                                               vote_average:   nil,
                                               adult:          nil,
                                               tmdb_id:        nil
                                            }
  end
end
