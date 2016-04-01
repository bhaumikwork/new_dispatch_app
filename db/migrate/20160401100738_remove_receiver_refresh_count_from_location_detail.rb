class RemoveReceiverRefreshCountFromLocationDetail < ActiveRecord::Migration
  def change
    remove_column :location_details, :receiver_refresh_count, :integer
  end
end
