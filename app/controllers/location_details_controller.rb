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
    query = params[:street_number] + ',' + params[:street_address] + ',' + params[:city] + ',' + params[:state]
    Geocoder::Configuration.timeout = 30000
    @current_location = Geocoder.search(request.location.ip).first
    @dest_location = Geocoder.search(query).first
    geteta("origins="+ @current_location.latitude.to_s+","+@current_location.longitude.to_s+"&destinations="+@dest_location.latitude.to_s+","+@dest_location.longitude.to_s)
    current_dispatcher.location_details.create(source_lat:@current_location.latitude,source_long:@current_location.longitude,dest_lat:@dest_location.latitude,dest_long:@dest_location.longitude,eta:@eta)
    logger.info"<=sabbb====#{@current_location.data}======>"
    logger.info"<=sa====#{@current_location.latitude}====lll===#{@current_location.longitude}=>"
    
  end

  def geteta(points)
    logger.info"<=points====#{points}======>"
    url = URI("https://maps.googleapis.com/maps/api/distancematrix/xml?units=imperial&"+points)
    logger.info"<=url====#{url}======>"
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    @response = response.read_body
    @response = Hash.from_xml(@response)
    @eta = @response["DistanceMatrixResponse"]["row"]["element"]["duration"]["value"].to_i/60.0
    @eta = @eta.round
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
end
