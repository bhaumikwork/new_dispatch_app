json.array!(@location_details) do |location_detail|
  json.extract! location_detail, :id, :dest_lat, :dest_long, :source_lat, :source_long, :eta, :url_token, :dispatcher_id
  json.url location_detail_url(location_detail, format: :json)
end
