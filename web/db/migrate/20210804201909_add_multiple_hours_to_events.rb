class AddMultipleHoursToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :multiple_hours, :boolean, default: false
  end
end
