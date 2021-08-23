# frozen_string_literal: true

class LocationAndTimeSlot < ActiveRecord::Base
  belongs_to :vaccination_location
  belongs_to :vaccination_time_slot
  belongs_to :vaccine

  has_many :applications, dependent: :destroy
  validates  :vaccination_location_id,:vaccination_time_slot_id, :vaccine_id, presence: true

end
