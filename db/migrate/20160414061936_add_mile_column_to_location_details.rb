class AddMileColumnToLocationDetails < ActiveRecord::Migration
  def change
    add_column :location_details, :curr_mile, :float, default: 0.0
    rename_column :location_details, :next_refresh_time, :next_refresh_second
    add_column :location_details, :next_refresh_time, :datetime
    add_column :location_details, :tracking_start_time, :datetime
  end
end
