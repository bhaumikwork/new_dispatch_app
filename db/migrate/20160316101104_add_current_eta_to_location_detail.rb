class AddCurrentEtaToLocationDetail < ActiveRecord::Migration
  def change
    add_column :location_details, :current_eta, :integer
  end
end
