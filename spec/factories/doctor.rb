# frozen_string_literal: true

FactoryBot.define do
  factory :doctor do
    sequence(:email) { |n| "doctor_test#{n}@example.com" }
    password { 'sometestpass' }
    admin
    sequence(:first_name) { |n| "doctor#{n}" }
    sequence(:last_name) { |n| "test#{n}" }
  end
end
