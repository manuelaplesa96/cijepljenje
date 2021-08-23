# frozen_string_literal: true

FactoryBot.define do
  factory :super_user do
    sequence(:email) { |n| "superuser_test#{n}@example.com" }
    password { 'sometestpass' }
    admin
    sector { 'Medical Institution Workers' }
  end
end
