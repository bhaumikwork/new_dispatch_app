class VendorsController < ApplicationController
	before_action :authenticate_vendor!

  def index
  	@ten_location = LocationDetail.order('id').last(10)
  	# @status = LocationDetail.order("id desc").limit(10).pluck(:status)
  end

  def vendor_map
  	@ten_location = LocationDetail.order('id').last(10).select {|r| r.tracking? }
  	@ten_location = @ten_location.map { |r| [r.dispatcher.first_name, r.curr_lat, r.curr_long] }
  end
end
