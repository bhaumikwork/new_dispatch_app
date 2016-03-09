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
