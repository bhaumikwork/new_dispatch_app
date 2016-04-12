class LocationDetail < ActiveRecord::Base
  enum status: { pending: 0, tracking: 1, reached: 2, terminated: 3 }
  belongs_to :dispatcher
  before_create :create_url_token

  def create_url_token
    url_token = Array.new(15){rand(36).to_s(36)}.join
    self.url_token = url_token
  end
end
