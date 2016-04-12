class HomeController < ApplicationController
	def dashboard
		if params[:url_token].present?
			LocationDetail.find_by_url_token(params[:url_token]).update(is_terminate: true)
		end
	end
	def home
		
	end

	def vender_home
		
	end
end
