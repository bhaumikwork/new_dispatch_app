class VendorsController < ApplicationController
	before_action :authenticate_vendor!

  def index
  	locations = LocationDetail.order('id').last(10)
  	@ten_location = []
  	locations.each do |location|
  		unless location.next_refresh_time.nil?
	  		if location.next_refresh_time + 15.minute < Time.zone.now() && location.tracking?
	  			location.terminated!
	  		end
	  	end
	  	@ten_location << location
  	end
  	# @status = LocationDetail.order("id desc").limit(10).pluck(:status)
  end

  def vendor_map
  	get_current_location()
  end

  def get_new_location
  	get_current_location()
  	render json: { current_location: @ten_location_array }
  end

  private

  	def get_current_location
  		@ten_location = LocationDetail.order('id').last(10).select {|r| r.tracking? }
  		@ten_location_array = @ten_location.map { |r| [r.dispatcher.first_name, r.curr_lat, r.curr_long] }
  	end
end
