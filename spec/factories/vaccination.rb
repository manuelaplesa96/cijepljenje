# frozen_string_literal: true

FactoryBot.define do
  factory :vaccination do
    application { create(:application_with_mbo) }
    vaccine { create(:vaccine) }
    vaccination_time_slot { create(:vaccination_time_slot) }
    vaccination_worker { create(:vaccination_worker) }
    dose_number { 1 }
  end
end
