class AddReferenceToApplication < ActiveRecord::Migration[6.1]
  def change
    change_table :applications do |t|
      t.string :reference
    end
  end
end
