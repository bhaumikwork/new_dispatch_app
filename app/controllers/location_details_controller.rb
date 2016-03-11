class LocationDetailsController < ApplicationController
  before_action :set_location_detail, only: [:show, :edit, :update, :destroy]

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
    @location_detail = current_dispatcher.location_details.create(source_lat:params[:curr_lat],source_long:params[:curr_long],dest_lat:@dest_location.latitude,dest_long:@dest_location.longitude,eta:@eta,curr_lat:params[:curr_lat],curr_long:params[:curr_long])
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
    else
      @error = true
    end
    logger.info"<=eta====#{@eta}======>"
  end

  def tracking_result
    @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    set_source_and_dest_points(@location_detail.source_lat,@location_detail.source_long,@location_detail.dest_lat,@location_detail.dest_long)
    @eta = @location_detail.eta
  end

  def refresh_tracking_result
    @location_detail = LocationDetail.find_by_url_token(params[:url_token])
    @location_detail.update(curr_lat:params[:curr_lat],curr_long:params[:curr_long]) if @location_detail.dispatcher == current_dispatcher
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
    @location_detail.update(is_reached: true) if @eta <= 2
    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location_detail
      @location_detail = LocationDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_detail_params
      params.require(:location_detail).permit(:dest_lat, :dest_long, :source_lat, :source_long, :eta, :url_token, :dispatcher_id)
    end
    #set source and dest lat-long
    def set_source_and_dest_points(source_lat,source_long,dest_lat,dest_long)
      @source_point = source_lat.to_s+","+source_long.to_s
      logger.info"<===spoint=====#{@source_point}======>"
      @dest_point= dest_lat.to_s+","+dest_long.to_s
    end
end
