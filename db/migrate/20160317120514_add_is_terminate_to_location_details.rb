class AddIsTerminateToLocationDetails < ActiveRecord::Migration
  def change
    add_column :location_details, :is_terminate, :boolean,default: false
  end
end
