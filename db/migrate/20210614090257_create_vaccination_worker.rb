# frozen_string_literal: true

class CreateVaccinationWorker < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_workers do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.belongs_to :admin, foreign_key: true
      t.belongs_to :vaccination_location, foreign_key: true
      t.string :start_work_time
      t.string :end_work_time
      t.string :time_zone

      t.timestamps
    end
  end
end
