class LocationDetailsController < ApplicationController
  before_action :set_location_detail, only: [:show, :edit, :update, :destroy]
  after_action :set_refresh_count,only: [:refresh_tracking_result,:tracking_result]

  # GET /location_details
  # GET /location_details.json
  def index
    @location_details = LocationDetail.all
  end

  # GET /location_details/1
  # GET /location_details/1.json
  def show
  end

  # GET /location_details/new
  def new
    @location_detail = LocationDetail.new
  end

  # GET /location_details/1/edit
  def edit
  end

  # POST /location_details
  # POST /location_details.json
  def create
    @location_detail = LocationDetail.new(location_detail_params)

    respond_to do |format|
      if @location_detail.save
        format.html { redirect_to @location_detail, notice: 'Location detail was successfully created.' }
        format.json { render :show, status: :created, location: @location_detail }
      else
        format.html { render :new }
        format.json { render json: @location_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /location_details/1
  # PATCH/PUT /location_details/1.json
  def update
    respond_to do |format|
      if @location_detail.update(location_detail_params)
        format.html { redirect_to @location_detail, notice: 'Location detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @location_detail }
      else
        format.html { render :edit }
        format.json { render json: @location_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /location_details/1
  # DELETE /location_details/1.json
  def destroy
    @location_detail.destroy
    respond_to do |format|
      format.html { redirect_to location_details_url, notice: 'Location detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def location_detail_popup
    respond_to :js
  end
  def location_detail
    query = params[:address]
    Geocoder::Configuration.timeout = 10000
    # @current_location = Geocoder.search(request.location.ip).first
    @dest_location = Geocoder.search(query).first
    # set_source_and_dest_points(@current_location.latitude,@current_location.longitude,@dest_location.latitude,@dest_location.longitude)
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
    # @location_detail = LocationDetail.first
    # logger.info"<=sabbb====#{@current_location.data}======>"
    # logger.info"<=sa====#{@current_location.latitude}====lll===#{@current_location.longitude}=>"
    respond_to :js
  end

  def geteta
    url = URI("https://maps.googleapis.com/maps/api/distancematrix/xml?units=imperial&origins=#{@source_point}&destinations=#{@dest_point}")
    logger.info"<=url====#{url}======>"
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    @response = response.read_body
    @response = Hash.from_xml(@response)
    logger.info"<=eta response====#{@response}======>"
    @error = false
    if @response["DistanceMatrixResponse"]["row"]["element"]["status"] == "OK"
      @eta = @response["DistanceMatrixResponse"]["row"]["element"]["duration"]["value"].to_i/60.0
      @eta = @eta.round
      @eta_min = (@eta)%60
      @eta_hr = (@eta)/60
    else
      @error = true
    end
    logger.info"<=eta====#{@eta}======>"
  end

  def tracking_result
    @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    if @location_detail.dispatcher == current_dispatcher
      @is_display = true if @location_detail.dispatcher_refresh_count < 3
    else
      @is_display = true if @location_detail.receiver_refresh_count < 3
    end
    if @is_display
      set_source_and_dest_points(@location_detail.source_lat,@location_detail.source_long,@location_detail.dest_lat,@location_detail.dest_long)
      @eta = @location_detail.eta
      @eta_min = (@eta)%60
      @eta_hr = (@eta)/60
      set_timer_vars
      logger.info"<=timer====#{@timer_hr}===#{@timer_min}====>"
    end
  end

  def refresh_tracking_result
    @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    if @location_detail.dispatcher == current_dispatcher
      @is_display = true if @location_detail.dispatcher_refresh_count < 3
    else
      @is_display = true if @location_detail.receiver_refresh_count < 3
    end
    if @is_display
      if @location_detail.dispatcher == current_dispatcher
        temp = @location_detail.update(curr_lat:params[:curr_lat],curr_long:params[:curr_long])
        logger.info"<==updates====#{temp}==========>"
        logger.info"<==updates=rec===#{@location_detail.inspect}==========>"
      end
      Geocoder::Configuration.timeout = 10000
      # @current_location = Geocoder.search(request.location.ip).first
      set_source_and_dest_points(@location_detail.curr_lat,@location_detail.curr_long,@location_detail.dest_lat,@location_detail.dest_long)
      # set_source_and_dest_points(@current_location.latitude,@current_location.longitude,@location_detail.dest_lat,@location_detail.dest_long)
      
      # bapunagar
      # set_source_and_dest_points(23.0333,72.6167,@location_detail.dest_lat,@location_detail.dest_long)

      # andhajan    23.034613,72.536014
      # set_source_and_dest_points(23.034613,72.536014,@location_detail.dest_lat,@location_detail.dest_long)
      
      #dinner bell  23.052180,72.537378
      # set_source_and_dest_points(23.052180,72.537378,@location_detail.dest_lat,@location_detail.dest_long)
      
      geteta
      @location_detail.update(current_eta: @eta,eta_calc_time:Time.zone.now) if @location_detail.dispatcher == current_dispatcher
      set_timer_vars
      if @eta <= 2
        @location_detail.update(is_reached: true,current_eta: @eta) 
      end
    end
    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location_detail
      @location_detail = LocationDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_detail_params
      params.require(:location_detail).permit(:dest_lat, :dest_long, :source_lat, :source_long, :eta, :url_token, :dispatcher_id,:curr_lat,:curr_long)
    end
    #set source and dest lat-long
    def set_source_and_dest_points(source_lat,source_long,dest_lat,dest_long)
      @source_point = source_lat.to_s+","+source_long.to_s
      logger.info"<===spoint=====#{@source_point}======>"
      @dest_point= dest_lat.to_s+","+dest_long.to_s
    end
    def set_timer_vars
      logger.info"<=time====#{Time.zone}====#{Time.zone.now}=======#{@location_detail.eta_calc_time}==>"
      @timer_sec = ((Time.zone.now - @location_detail.eta_calc_time).round % 60)
      logger.info"<=time diff===#{@timer_sec}=======#{Time.zone.now - @location_detail.eta_calc_time}==>"
      diff = ((Time.zone.now - @location_detail.eta_calc_time)/60).round
      @tmp_eta = @location_detail.current_eta - (diff)
      @tmp_eta = 0 if @tmp_eta < 0
      logger.info"<=tmp eta===#{@tmp_eta}=======ll==>"
      
      @timer_hr = @tmp_eta/60 
      @timer_min = @tmp_eta%60
      unless diff > 0 
        @timer_sec = 55
        @timer_min = @timer_min-1 unless @tmp_eta < @location_detail.current_eta
      end
      @timer_hr = @timer_hr < 0 ? 0 : @timer_hr
      @timer_min = @timer_min < 0 ? 1 : @timer_min
    end
    def set_refresh_count
      if @location_detail.dispatcher == current_dispatcher
        @location_detail.increment!(:dispatcher_refresh_count)
        logger.info"<====in set refresh count===if ==>"
      else
        @location_detail.increment!(:receiver_refresh_count)
        logger.info"<====in set refresh count===else ==>"
      end
    end
end
