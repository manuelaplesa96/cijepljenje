# frozen_string_literal: true

class Doctor < ActiveRecord::Base
  include AuthenticationAttributes

  has_secure_password

  belongs_to :admin
  has_many :applications, as: :author, dependent: :destroy

  validates :first_name, :last_name, presence: true
end
