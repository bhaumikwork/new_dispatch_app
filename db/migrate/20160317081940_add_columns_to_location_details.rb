class AddColumnsToLocationDetails < ActiveRecord::Migration
  def change
    add_column :location_details, :receiver_refresh_count, :integer,default: 0
    add_column :location_details, :dispatcher_refresh_count, :integer,default: 0
  end
end
