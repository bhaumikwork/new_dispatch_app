class AddEtaCalcTimeToLocationDetail < ActiveRecord::Migration
  def change
    add_column :location_details, :eta_calc_time, :datetime
  end
end
