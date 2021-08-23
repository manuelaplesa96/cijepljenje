# frozen_string_literal: true

class VaccinationTimeSlot < ActiveRecord::Base
  has_many :location_and_time_slots, dependent: :destroy
  has_many :vaccination_locations, through: :location_and_time_slots
  has_many :vaccinations

  validates :date_and_time, presence: true
end
