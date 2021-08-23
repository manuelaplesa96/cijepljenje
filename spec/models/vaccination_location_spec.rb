# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VaccinationLocation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:admin) }
    it { is_expected.to have_many(:location_and_time_slots).dependent(:destroy) }
    it { is_expected.to have_many(:vaccination_time_slots).through(:location_and_time_slots) }
    it { is_expected.to have_many(:vaccination_workers).dependent(:destroy) }
    it { is_expected.to have_many(:vaccines).dependent(:destroy) }
    it { is_expected.to have_many(:applications).dependent(:destroy) }
  end

  describe 'validations are correct' do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:county) }
  end
end
