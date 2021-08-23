# frozen_string_literal: true

module AuthorizationAttributes
  extend ActiveSupport::Concern

  included do
    validates :email, :password_digest, presence: true
    validates :email, uniqueness: true
  end
end