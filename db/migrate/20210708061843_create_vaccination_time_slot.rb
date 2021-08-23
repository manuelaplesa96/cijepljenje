# frozen_string_literal: true

class CreateVaccinationTimeSlot < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_time_slots do |t|
      t.datetime :date_and_time

      t.timestamps
    end
  end
end
