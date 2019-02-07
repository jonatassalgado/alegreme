class CreateJoinTableEventOrganizer < ActiveRecord::Migration[5.2]
  def change
    create_join_table :events, :organizers do |t|
      t.index [:event_id, :organizer_id], unique: true
      t.index [:organizer_id, :event_id], unique: true
    end
  end
end
