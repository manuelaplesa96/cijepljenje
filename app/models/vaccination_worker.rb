# frozen_string_literal: true

class VaccinationWorker < ActiveRecord::Base
  include AuthenticationAttributes 
  has_secure_password

  belongs_to :admin
  has_many :vaccinations

  validates :start_work_time, :end_work_time, :time_zone, :vaccination_location_id, presence: true
end
