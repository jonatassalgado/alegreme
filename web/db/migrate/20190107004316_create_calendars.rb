class CreateCalendars < ActiveRecord::Migration[5.2]
  def change
    create_table :calendars do |t|
      t.datetime :day_time

      t.timestamps
    end
  end
end
