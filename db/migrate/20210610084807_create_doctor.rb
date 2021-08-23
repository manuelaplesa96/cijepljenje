# frozen_string_literal: true

class CreateDoctor < ActiveRecord::Migration[6.1]
  def change
    create_table :doctors do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.belongs_to :admin, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false

      t.timestamps
    end
  end
end
