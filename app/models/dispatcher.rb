class Dispatcher < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :location_details,dependent: :destroy

  def name
    first_name.present? ? first_name : last_name.present? ? last_name : email
  end
  def full_name
    first_name + " " + last_name
  end

  # on confirmation time ask for password for this below methods are override
  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def terminate_running_tracker
    self.location_details.where(status: 1).update_all(status: 3)
  end
end
