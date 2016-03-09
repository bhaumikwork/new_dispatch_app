require "rails_helper"

RSpec.describe LocationDetailsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/location_details").to route_to("location_details#index")
    end

    it "routes to #new" do
      expect(:get => "/location_details/new").to route_to("location_details#new")
    end

    it "routes to #show" do
      expect(:get => "/location_details/1").to route_to("location_details#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/location_details/1/edit").to route_to("location_details#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/location_details").to route_to("location_details#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/location_details/1").to route_to("location_details#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/location_details/1").to route_to("location_details#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/location_details/1").to route_to("location_details#destroy", :id => "1")
    end

  end
end
