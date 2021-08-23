# frozen_string_literal: true

module AuthenticationAttributes
  extend ActiveSupport::Concern

  included do
    validates :email, :password_digest, presence: true
    validates :email, uniqueness: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  end
end