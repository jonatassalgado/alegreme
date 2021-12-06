class AddSourceNameToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :source_name, :string
  end
end
