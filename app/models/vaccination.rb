# frozen_string_literal: true

class Vaccination < ActiveRecord::Base
  belongs_to :application
  belongs_to :vaccine
  belongs_to :vaccination_time_slot
  belongs_to :vaccination_worker

  validates :application_id, :vaccine_id, :vaccination_time_slot_id, :vaccination_worker_id, :dose_number, presence: true
end
