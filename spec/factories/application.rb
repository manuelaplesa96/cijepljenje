# frozen_string_literal: true

FactoryBot.define do
  factory :application do
    first_name { 'Person' }
    last_name { 'Surname' }
    birth_date { Date.new(1996, 10, 12) }
    gender { 'F' }
    email { 'person@example.com' }
    chronic_patient { false }
    status { Application.statuses[:u_obradi] }
    vaccination_location { create(:vaccination_location) }
    location_and_time_slot { create(:location_and_time_slot) }
    author { create(:doctor) }
    reference { 'Person-Surname-' + "#{SecureRandom.alphanumeric(8).upcase}" }

    factory :application_with_oib do
      oib { rand(100_000_000_00..999_999_999_99) }
    end

    factory :application_with_mbo do
      mbo { rand(100_000_000..999_999_999) }
    end
  end
end
