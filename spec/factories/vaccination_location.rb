# frozen_string_literal: true

FactoryBot.define do
  factory :vaccination_location do
    sequence(:address) { |n| "Testna ulica #{n}" }
    admin
    city { 'Zagreb' }
    county { 'Grad Zagreb' }
  end
end
