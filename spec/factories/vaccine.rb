# frozen_string_literal: true

FactoryBot.define do
  factory :vaccine do
    name { 'Test Vaccine' }
    sequence(:series) { |n| "ABC-#{n}" }
    doses_number { 2 }
    amount { 20 }
    min_days_between_doses { 24 }
    max_days_between_doses { 15 }
    start_date { DateTime.now }
    expiration_date { DateTime.now + 42.days }
    vaccination_location_id { create(:vaccination_location).id }
    admin
  end
end
