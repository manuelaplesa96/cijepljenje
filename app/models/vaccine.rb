# frozen_string_literal: true

class Vaccine < ActiveRecord::Base
  belongs_to :admin
  has_many :vaccinations
  has_many :location_and_time_slot

  validates :name, :series, :doses_number, :amount, :min_days_between_doses, :max_days_between_doses, :start_date, :expiration_date, :vaccination_location_id, presence: true
  validates :series, uniqueness: true

  def get_available_days
    max_days_between_doses - min_days_between_doses
  end
end
