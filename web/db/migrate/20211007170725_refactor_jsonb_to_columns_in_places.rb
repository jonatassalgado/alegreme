class RefactorJsonbToColumnsInPlaces < ActiveRecord::Migration[6.0]
	def change
		add_column :places, :google_id, :string
		add_column :places, :name, :string
		add_column :places, :description, :text
		add_column :places, :phone_number, :string
		add_column :places, :website, :string
		add_column :places, :address, :string
		add_column :places, :cep, :string
		add_column :places, :city, :string
		add_column :places, :latitude, :decimal, { precision: 10, scale: 6 }
		add_column :places, :longitude, :decimal, { precision: 10, scale: 6 }
		add_column :places, :neighborhood, :string
	end
end
