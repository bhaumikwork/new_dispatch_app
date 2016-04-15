class LocationDetailsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :set_location_detail,only: [:tracking_result,:refresh_tracking_result, :set_next_refresh_second, :get_new_time]
  before_action :check_link_generator,only: [:tracking_result,:refresh_tracking_result]
  after_action :set_refresh_count,only: [:refresh_tracking_result,:tracking_result]
  before_action :update_status, only: [:tracking_result]
  # after_action :check_link_generator,only: [:set_location_detail]

  #if eta less then this time then we consider as reached
  $eta_time=1
  $eta_meter=10

  # just opens a popup for taking destination address
  def location_detail_popup
    respond_to :js
  end
  
  # based on source and destination generatos random link
  def location_detail
    query = params[:address]
    Geocoder::Configuration.timeout = 10000
    @dest_location = Geocoder.search(query).first
    logger.info"<====================#{@dest_location.inspect}=========================>"
    logger.info"<=========latitude===========#{@dest_location.latitude}=========================>"
    logger.info"<=========longitude===========#{@dest_location.longitude}=========================>"
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
        current_eta:@eta,
        curr_mile:@curr_mile
      )
    end
  end

  # generates image and dispalay it.
  def tracking_result
    @location_detail.update_attributes(eta_calc_time: Time.zone.now) if @location_detail.eta_calc_time.nil?

    if @link_generator
      @time_variation = 0
      # @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 3
    else
      @time_variation = 10000
      # @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 4
    end
    set_source_and_dest_points(@location_detail.source_lat,@location_detail.source_long,@location_detail.dest_lat,@location_detail.dest_long)
    @eta = @location_detail.eta
    # @eta = 7 # testing value
    @eta_min = (@eta)%60
    @eta_hr = (@eta)/60
    @curr_mile = @location_detail.curr_mile
    check_for_reached
    # refresh_image
    logger.info"========eta======#{@eta}================="
    logger.info"=======eta_min========#{@eta_min}================"
    logger.info"========eta_hr=======#{@eta_hr}================"
    logger.info"======@time_variation===========#{@time_variation}=============="
  end

  # At timer ends this will refresh tracking results
  def refresh_tracking_result
    if @link_generator
      @time_variation = 0
      # @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 3
    else
      @time_variation = 10000
      # @is_api_limit_exceed = true if @location_detail.dispatcher_refresh_count > 4
    end
    if !@is_api_limit_exceed
      if @link_generator && params[:curr_lat].present? && params[:curr_long].present?
        @location_detail.update(curr_lat:params[:curr_lat],curr_long:params[:curr_long])
      end
      set_source_and_dest_points(@location_detail.curr_lat,@location_detail.curr_long,@location_detail.dest_lat,@location_detail.dest_long)

      geteta
      if @link_generator && !@error
        @location_detail.update(current_eta: @eta, eta_calc_time:Time.zone.now, curr_mile: @curr_mile)
        # refresh_image
        check_for_reached
      end
    else
      set_source_and_dest_points(@location_detail.curr_lat,@location_detail.curr_long,@location_detail.dest_lat,@location_detail.dest_long)
    end
    respond_to :js
  end


  def get_new_time
    check_next_refresh_time()
    if @location_detail.dispatcher_refresh_count > params[:old_refresh_count].to_i || @location_detail.terminated?
      render json: {update: true, record: @location_detail.id,eta_calc_time: @location_detail.eta_calc_time,current_eta: @location_detail.current_eta, refresh_count: @location_detail.dispatcher_refresh_count, next_refresh_time: @location_detail.next_refresh_time, track_status: @location_detail.status, current_mile: number_with_precision(@location_detail.curr_mile/1610, precision: 2), index: params[:index]}
    else
      render json: {update: false, record: @location_detail.id, index: params[:index]}
    end
  end

  private
    #will set location detail
    def set_location_detail
      @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    end

    # calls distancematrix api with source-destination points and get ETA
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
      unless @response["DistanceMatrixResponse"]["status"] == "OVER_QUERY_LIMIT"
        if @response["DistanceMatrixResponse"]["row"]["element"]["status"] == "OK"
          @eta = @response["DistanceMatrixResponse"]["row"]["element"]["duration"]["value"].to_i/60.0
          # @eta = 300/60.0 # testing value
          # @eta = 7
          @eta = @eta.round
          @eta_min = (@eta)%60
          @eta_hr = (@eta)/60
          @curr_mile = @response["DistanceMatrixResponse"]["row"]["element"]["distance"]["value"].to_f
        else
          @error = true
        end
      else
        @error = true
        @error_info = { error: true, status: @response["DistanceMatrixResponse"]["status"], err_msg: @response["DistanceMatrixResponse"]["error_message"].split('.')[0] }
      end
      logger.info"<=====response===========#{@response.inspect}===============>"
    end
    #set source and dest lat-long for map
    def refresh_image
      if @link_generator && !@is_api_limit_exceed
        data = {"start": @source_point,"end": @dest_point}.to_json

        url = URI(ENV["phantomJs_url"])

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["content-type"] = 'application/json'
        request.body = data

        response = http.request(request)
        res = JSON.parse response.read_body
        logger.info"<=====res===========#{res.inspect}===============>"
        @location_detail.update(image_url: res["url"])
      end
    end
    
    #sets source and destination point as a string
    def set_source_and_dest_points(source_lat,source_long,dest_lat,dest_long)
      @source_point = source_lat.to_s+","+source_long.to_s
      @dest_point= dest_lat.to_s+","+dest_long.to_s
    end

    #increase refresh count on refresh 
    def set_refresh_count
      @location_detail.increment!(:dispatcher_refresh_count) if @link_generator
    end
    
    #check current_dispatcher is generator of @location_detail or not
    def check_link_generator
      @link_generator = @location_detail.dispatcher == current_dispatcher ? true : false
    end

    def update_status
      if @location_detail.tracking_start_time.nil?
        @location_detail.tracking!
        @location_detail.update_attributes(tracking_start_time: Time.zone.now)
      end
    end

    def check_for_reached
      if @eta <= 5
        if @eta <= $eta_time || @curr_mile <= $eta_meter
          @location_detail.update(is_reached: true,current_eta: @eta)
          @location_detail.reached!
        else
          @location_detail.update(next_refresh_second: 10)
          @location_detail.update(next_refresh_time: @location_detail.eta_calc_time + 10.second)
        end
      else
        @location_detail.update(next_refresh_time: @location_detail.eta_calc_time + (@eta/2.0).round.minute)
        logger.info"=========ETA======#{@eta}============================="
        logger.info"=========ETA/2======#{@eta/2.0}============================="
        logger.info"=========next_refresh_time======#{@location_detail.next_refresh_time}============================="
        logger.info"=========eta_calc_time======#{@location_detail.eta_calc_time}============================="
      end
    end

    def check_next_refresh_time
      # unless @location_detail.next_refresh_time.nil?
      #   if @location_detail.next_refresh_time < Time.zone.now()
      #     @location_detail.terminated!
      #   end
      # end
    end

end
