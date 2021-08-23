class AddStatusToApplication < ActiveRecord::Migration[6.1]
  def up
    change_column :applications, :status, :string, default: Application.statuses[:u_obradi], null: false
  end

  def down
    change_column :applications, :status, :string, default: nil, null: true
  end
end
