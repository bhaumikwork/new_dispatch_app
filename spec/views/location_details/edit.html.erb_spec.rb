require 'rails_helper'

RSpec.describe "location_details/edit", type: :view do
  before(:each) do
    @location_detail = assign(:location_detail, LocationDetail.create!(
      :dest_lat => "MyString",
      :dest_long => "MyString",
      :source_lat => "MyString",
      :source_long => "MyString",
      :eta => 1,
      :url_token => "MyString",
      :dispatcher => nil
    ))
  end

  it "renders the edit location_detail form" do
    render

    assert_select "form[action=?][method=?]", location_detail_path(@location_detail), "post" do

      assert_select "input#location_detail_dest_lat[name=?]", "location_detail[dest_lat]"

      assert_select "input#location_detail_dest_long[name=?]", "location_detail[dest_long]"

      assert_select "input#location_detail_source_lat[name=?]", "location_detail[source_lat]"

      assert_select "input#location_detail_source_long[name=?]", "location_detail[source_long]"

      assert_select "input#location_detail_eta[name=?]", "location_detail[eta]"

      assert_select "input#location_detail_url_token[name=?]", "location_detail[url_token]"

      assert_select "input#location_detail_dispatcher_id[name=?]", "location_detail[dispatcher_id]"
    end
  end
end
