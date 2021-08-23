# frozen_string_literal: true

class VaccinationLocation < ActiveRecord::Base
  belongs_to :admin
  has_many :location_and_time_slots, dependent: :destroy
  has_many :vaccination_time_slots, through: :location_and_time_slots
  has_many :vaccination_workers, dependent: :destroy
  has_many :vaccines, dependent: :destroy
  has_many :applications, dependent: :destroy

  validates :address, :city, :county, presence: true
end
