# frozen_string_literal: true

class CreateVaccine < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccines do |t|
      t.belongs_to :admin, foreign_key: true
      t.belongs_to :vaccination_location, foreign_key: true
      t.string :name
      t.string :series
      t.integer :doses_number
      t.integer :amount
      t.integer :min_days_between_doses
      t.integer :max_days_between_doses
      t.datetime :start_date
      t.datetime :expiration_date

      t.timestamps
    end
  end
end
