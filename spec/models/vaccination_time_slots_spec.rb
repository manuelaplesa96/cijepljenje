# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VaccinationTimeSlot, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:location_and_time_slots).dependent(:destroy) }
    it { is_expected.to have_many(:vaccination_locations).through(:location_and_time_slots) }
    it { is_expected.to have_many(:vaccinations) }
  end

  describe 'validations are correct' do
    it { is_expected.to validate_presence_of(:date_and_time) }
  end
end
