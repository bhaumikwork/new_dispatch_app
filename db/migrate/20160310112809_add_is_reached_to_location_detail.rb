class AddIsReachedToLocationDetail < ActiveRecord::Migration
  def change
    add_column :location_details, :is_reached, :boolean, default: false
  end
end
