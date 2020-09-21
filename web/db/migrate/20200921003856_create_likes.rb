class CreateLikes < ActiveRecord::Migration[6.0]
  def change
    create_table :likes do |t|
      t.belongs_to :event, index: true
      t.belongs_to :user, index: true
      t.string :sentiment, null: false
      t.timestamps
    end
  end
end
