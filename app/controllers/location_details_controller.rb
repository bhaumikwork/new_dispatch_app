class LocationDetailsController < ApplicationController
  after_action :set_refresh_count,only: [:refresh_tracking_result,:tracking_result]
  $eta_time=2

  def location_detail_popup
    respond_to :js
  end
  def location_detail
    query = params[:address]
    Geocoder::Configuration.timeout = 10000
    @dest_location = Geocoder.search(query).first
    set_source_and_dest_points(params[:curr_lat],params[:curr_long],@dest_location.latitude,@dest_location.longitude)
    geteta
    unless @error
      @location_detail = current_dispatcher.location_details.create(
        source_lat:params[:curr_lat],
        source_long:params[:curr_long],
        dest_lat:@dest_location.latitude,
        dest_long:@dest_location.longitude,
        eta:@eta,
        curr_lat:params[:curr_lat],
        curr_long:params[:curr_long],
        eta_calc_time:Time.zone.now,
        current_eta:@eta
      )
    end
  end

  def geteta
    url = URI("https://maps.googleapis.com/maps/api/distancematrix/xml?units=imperial&origins=#{@source_point}&destinations=#{@dest_point}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    @response = response.read_body
    @response = Hash.from_xml(@response)
    @error = false
    logger.info"========#{@response}============="
    if @response["DistanceMatrixResponse"]["row"]["element"]["status"] == "OK"
      @eta = @response["DistanceMatrixResponse"]["row"]["element"]["duration"]["value"].to_i/60.0
      @eta = @eta.round
      @eta_min = (@eta)%60
      @eta_hr = (@eta)/60
    else
      @error = true
    end
  end

  def tracking_result
    @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    if @location_detail.dispatcher == current_dispatcher
      @time_variation = 0
      @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 3
    else
      @time_variation = 2
      @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 4
    end
    set_source_and_dest_points(@location_detail.source_lat,@location_detail.source_long,@location_detail.dest_lat,@location_detail.dest_long)
    @eta = @location_detail.eta
    @eta_min = (@eta)%60
    @eta_hr = (@eta)/60
    set_terminate_var
    # logger.info exec("node_modules/phantomjs/bin/phantomjs screen_capture.js #{params[:url_token]}")
    if @location_detail.dispatcher == current_dispatcher
      map_url = URI.encode(load_map_url(params[:url_token]))
      data = {"start": @source_point,"end": @dest_point}.to_json

      logger.info"<====cmd run=address=#{data}===>"

      url = URI("https://phantomss.herokuapp.com/screenshot")
    
      # url = URI("http://127.0.0.1:4000/screenshot")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/json'
      request.body = data

      response = http.request(request)
      logger.info"=====#{response.read_body}========="
      res = JSON.parse response.read_body
      @location_detail.update(image_url: res["url"])
    end

  end

  def refresh_tracking_result
    @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    if @location_detail.dispatcher == current_dispatcher
      @time_variation = 0
      @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 3
    else
      @time_variation = 2
      @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 4
    end
    if !@is_api_limit_exceed
      if @location_detail.dispatcher == current_dispatcher
        temp = @location_detail.update(curr_lat:params[:curr_lat],curr_long:params[:curr_long])
      end
      set_source_and_dest_points(@location_detail.curr_lat,@location_detail.curr_long,@location_detail.dest_lat,@location_detail.dest_long)
      
      geteta
      @location_detail.update(current_eta: @eta,eta_calc_time:Time.zone.now) if @location_detail.dispatcher == current_dispatcher
      if @eta <= $eta_time
        @location_detail.update(is_reached: true,current_eta: @eta) 
      end
      set_terminate_var
    else
      set_source_and_dest_points(@location_detail.curr_lat,@location_detail.curr_long,@location_detail.dest_lat,@location_detail.dest_long)
    end
    respond_to :js
  end
  def load_map
    @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    set_source_and_dest_points(@location_detail.source_lat,@location_detail.source_long,@location_detail.dest_lat,@location_detail.dest_long)
    set_terminate_var
    # render layout: false
  end

  private
    #set source and dest lat-long for map
    def set_source_and_dest_points(source_lat,source_long,dest_lat,dest_long)
      @source_point = source_lat.to_s+","+source_long.to_s
      @dest_point= dest_lat.to_s+","+dest_long.to_s
    end

    def set_terminate_var
      if Time.zone.now > (@location_detail.eta_calc_time + @location_detail.current_eta.minutes)
        @is_terminate = true
      end
    end

    def set_refresh_count
      @location_detail.increment!(:dispatcher_refresh_count) if @location_detail.dispatcher == current_dispatcher
    end
end
