class VendorsController < ApplicationController
	before_action :authenticate_vendor!

  def index
  	@ten_location = LocationDetail.order('id').last(10)
  	# @status = LocationDetail.order("id desc").limit(10).pluck(:status)
  end
end
