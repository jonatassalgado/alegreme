class CreateJoinTableEventCategory < ActiveRecord::Migration[5.2]
  def change
    create_join_table :events, :categories do |t|
      t.index [:event_id, :category_id], unique: true
      t.index [:category_id, :event_id], unique: true
    end
  end
end
