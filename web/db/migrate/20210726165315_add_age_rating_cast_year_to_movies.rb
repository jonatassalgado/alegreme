class AddAgeRatingCastYearToMovies < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :age_rating, :string
    add_column :movies, :cast, :text, array: true, default: []
    add_column :movies, :year, :numeric
  end
end
