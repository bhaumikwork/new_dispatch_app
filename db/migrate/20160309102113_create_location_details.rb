class CreateLocationDetails < ActiveRecord::Migration
  def change
    create_table :location_details do |t|
      t.string :dest_lat
      t.string :dest_long
      t.string :source_lat
      t.string :source_long
      t.integer :eta
      t.string :url_token
      t.references :dispatcher, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
