class CreateApplication < ActiveRecord::Migration[6.1]
  def change
    create_table :applications do |t|
      t.belongs_to :vaccination_location, foreign_key: true
      t.belongs_to :location_and_time_slot, foreign_key: true
      t.references :author, polymorphic: true
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :gender
      t.bigint :oib
      t.bigint :mbo
      t.string :email
      t.string :sector
      t.bigint :phone_number
      t.boolean :chronic_patient
      t.string :status

      t.timestamps
    end
  end
end
