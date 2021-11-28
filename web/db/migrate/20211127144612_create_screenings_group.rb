class CreateScreeningsGroup < ActiveRecord::Migration[6.0]
  def change
    create_table :screening_groups do |t|
      t.belongs_to :cinema, index: true, foreign_key: true
      t.belongs_to :movie, index: true, foreign_key: true
      t.date :date
      t.timestamps
    end
    add_belongs_to :screenings, :screening_group, foreign_key: true
  end
end
