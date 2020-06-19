class AddMoviesTasteToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :taste, from: {
                                            events: {
                                              saved:          [],
                                              liked:          [],
                                              viewed:         [],
                                              disliked:       [],
                                              total_saves:    0,
                                              total_likes:    0,
                                              total_views:    0,
                                              total_dislikes: 0
                                            }
                                          },
                                          to: {
                                            events: {
                                              saved:          [],
                                              liked:          [],
                                              viewed:         [],
                                              disliked:       [],
                                              total_saves:    0,
                                              total_likes:    0,
                                              total_views:    0,
                                              total_dislikes: 0
                                            },
                                            movies: {
                                              saved:          [],
                                              liked:          [],
                                              viewed:         [],
                                              disliked:       [],
                                              total_saves:    0,
                                              total_likes:    0,
                                              total_views:    0,
                                              total_dislikes: 0
                                            }
                                          }
    add_column :movies, :entries, :jsonb, null: false, default: {
                                                          saved_by:       [],
                                                          liked_by:       [],
                                                          viewed_by:      [],
                                                          disliked_by:    [],
                                                          total_saves:    0,
                                                          total_likes:    0,
                                                          total_views:    0,
                                                          total_dislikes: 0
                                                      }

  end
end
