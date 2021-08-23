# frozen_string_literal: true

FactoryBot.define do
  factory :location_and_time_slot do
    vaccination_location { create(:vaccination_location) }
    vaccination_time_slot { create(:vaccination_time_slot) }
    vaccine { create(:vaccine) }
  end
end
