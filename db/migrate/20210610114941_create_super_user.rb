# frozen_string_literal: true

class CreateSuperUser < ActiveRecord::Migration[6.1]
  def change
    create_table :super_users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.belongs_to :admin, foreign_key: true
      t.string :sector

      t.timestamps
    end
  end
end
