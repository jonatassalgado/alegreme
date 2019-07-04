class CreateJoinTableEventCategory < ActiveRecord::Migration[5.2]
  def change
    create_join_table :events, :categories do |t|
      t.index [:event_id, :category_id]
      t.index [:category_id, :event_id]
    end
  end
end
