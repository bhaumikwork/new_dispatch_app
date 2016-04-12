class AddColumnToLocationDetails < ActiveRecord::Migration
  def change
    add_column :location_details, :next_refresh_time, :integer, default: 0
    add_column :location_details, :status, :integer, default: 0
  end
end
