class AddDestinationAddressToLocationDetail < ActiveRecord::Migration
  def change
    add_column :location_details, :destination_address, :text
  end
end
