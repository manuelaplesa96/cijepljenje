# frozen_string_literal: true

FactoryBot.define do
  factory :vaccination_worker do
    sequence(:email) { |n| "vaccination_worker_test#{n}@example.com" }
    password { 'sometestpass' }
    admin
    start_work_time { '08:00' }
    end_work_time { '13:00' }
    time_zone { 'Europe/Sarajevo' }
    vaccination_location_id { create(:vaccination_location).id }
  end
end
