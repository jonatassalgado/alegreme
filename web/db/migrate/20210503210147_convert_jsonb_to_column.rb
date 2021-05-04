class ConvertJsonbToColumn < ActiveRecord::Migration[6.0]
  def change
    enable_extension :pg_trgm
    add_column :events, :name, :string
    add_column :events, :prices, :text, array: true, default: []
    add_column :events, :source_url, :string
    add_column :events, :ticket_url, :string
    add_column :events, :description, :text
    add_column :events, :datetimes, :text, array: true, default: []
    add_index :events, :name
    add_index :events, :prices, using: 'gin'
  end
end
