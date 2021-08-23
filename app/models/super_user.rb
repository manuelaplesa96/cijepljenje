# frozen_string_literal: true

class SuperUser < ActiveRecord::Base
  include AuthenticationAttributes

  has_secure_password

  belongs_to :admin
  has_many :applications, as: :author, dependent: :destroy

  validates :sector, presence: true
end
