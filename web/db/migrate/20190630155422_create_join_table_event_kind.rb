class CreateJoinTableEventKind < ActiveRecord::Migration[5.2]
  def change
    create_join_table :events, :kinds do |t|
      t.index [:event_id, :kind_id]
      t.index [:kind_id, :event_id]
    end
  end
end
