# frozen_string_literal: true

class AddVaccineToLocationAndTimeSlot < ActiveRecord::Migration[6.1]
  def change
    change_table :location_and_time_slots do |t|
      t.belongs_to :vaccine, foreign_key: true
    end
  end
end
