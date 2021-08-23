# frozen_string_literal: true

class CreateVaccinationLocationAndVaccinationTimeSlot < ActiveRecord::Migration[6.1]
  def change
    create_table :location_and_time_slots do |t|
      t.belongs_to :vaccination_location, foreign_key: true
      t.belongs_to :vaccination_time_slot, foreign_key: true

      t.timestamps
    end
  end
end
