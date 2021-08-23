# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin_test#{n}@example.com" }
    password { 'sometestpass' }
  end
end
