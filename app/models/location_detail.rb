class LocationDetail < ActiveRecord::Base
  belongs_to :dispatcher
  before_create :create_url_token
  after_update :set_eta_calc_time

  def create_url_token
    url_token = Array.new(5){rand(36).to_s(36)}.join
    self.url_token = url_token
  end

  def set_eta_calc_time
		if self.current_eta_changed?
			puts"in model"
			self.update(eta_calc_time: self.updated_at)
		end 
	end
end
