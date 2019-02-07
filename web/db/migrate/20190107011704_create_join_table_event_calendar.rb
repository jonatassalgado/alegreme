class CreateJoinTableEventCalendar < ActiveRecord::Migration[5.2]
  def change
    create_join_table :events, :calendars do |t|
      t.index [:event_id, :calendar_id], unique: true
      t.index [:calendar_id, :event_id], unique: true
    end
  end
end
