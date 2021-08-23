# frozen_string_literal: true

class CreateVaccinationTable < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccinations do |t|
      t.belongs_to :application, foreign_key: true
      t.belongs_to :vaccine, foreign_key: true
      t.belongs_to :vaccination_time_slot, foreign_key: true
      t.belongs_to :vaccination_worker, foreign_key: true
      t.integer :dose_number

      t.timestamps
    end
  end
end
