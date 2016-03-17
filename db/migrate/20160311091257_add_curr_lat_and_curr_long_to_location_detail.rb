class AddCurrLatAndCurrLongToLocationDetail < ActiveRecord::Migration
  def change
    add_column :location_details, :curr_lat, :string
    add_column :location_details, :curr_long, :string
  end
end
