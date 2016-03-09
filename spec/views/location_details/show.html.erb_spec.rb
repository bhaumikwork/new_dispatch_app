require 'rails_helper'

RSpec.describe "location_details/show", type: :view do
  before(:each) do
    @location_detail = assign(:location_detail, LocationDetail.create!(
      :dest_lat => "Dest Lat",
      :dest_long => "Dest Long",
      :source_lat => "Source Lat",
      :source_long => "Source Long",
      :eta => 1,
      :url_token => "Url Token",
      :dispatcher => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Dest Lat/)
    expect(rendered).to match(/Dest Long/)
    expect(rendered).to match(/Source Lat/)
    expect(rendered).to match(/Source Long/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Url Token/)
    expect(rendered).to match(//)
  end
end
