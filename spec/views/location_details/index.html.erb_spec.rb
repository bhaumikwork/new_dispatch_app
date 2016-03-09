require 'rails_helper'

RSpec.describe "location_details/index", type: :view do
  before(:each) do
    assign(:location_details, [
      LocationDetail.create!(
        :dest_lat => "Dest Lat",
        :dest_long => "Dest Long",
        :source_lat => "Source Lat",
        :source_long => "Source Long",
        :eta => 1,
        :url_token => "Url Token",
        :dispatcher => nil
      ),
      LocationDetail.create!(
        :dest_lat => "Dest Lat",
        :dest_long => "Dest Long",
        :source_lat => "Source Lat",
        :source_long => "Source Long",
        :eta => 1,
        :url_token => "Url Token",
        :dispatcher => nil
      )
    ])
  end

  it "renders a list of location_details" do
    render
    assert_select "tr>td", :text => "Dest Lat".to_s, :count => 2
    assert_select "tr>td", :text => "Dest Long".to_s, :count => 2
    assert_select "tr>td", :text => "Source Lat".to_s, :count => 2
    assert_select "tr>td", :text => "Source Long".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Url Token".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
