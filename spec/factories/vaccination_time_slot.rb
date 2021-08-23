# frozen_string_literal: true

FactoryBot.define do
  factory :vaccination_time_slot do
    date_and_time { DateTime.now }
  end
end
