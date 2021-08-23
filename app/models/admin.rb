# frozen_string_literal: true

class Admin < ActiveRecord::Base
  has_secure_password

  has_many :doctors, dependent: :destroy
  has_many :super_users, dependent: :destroy
  has_many :vaccination_locations, dependent: :destroy
  has_many :vaccination_workers, dependent: :destroy
  has_many :vaccines, dependent: :destroy

  validates :email, :password_digest, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
