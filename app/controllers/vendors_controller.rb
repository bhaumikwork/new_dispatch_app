class VendorsController < ApplicationController
	before_action :authenticate_vendor!

  def index
  	@ten_location = LocationDetail.last(10)
  end
end
