class AddImageUrlToLocationDetail < ActiveRecord::Migration
  def change
    add_column :location_details, :image_url, :string
  end
end
