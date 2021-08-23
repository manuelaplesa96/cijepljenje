# frozen_string_literal: true

class CreateVaccinationLocation < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_locations do |t|
      t.string :address
      t.string :city
      t.string :county
      t.belongs_to :admin, foreign_key: true

      t.timestamps
    end
  end
end
