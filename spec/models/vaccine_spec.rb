# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vaccine, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:admin) }
    it { is_expected.to have_many(:vaccinations) }
    it { is_expected.to have_many(:location_and_time_slot) }
  end

  describe 'validations are correct' do
    let(:admin) { create(:admin) }
    let(:vaccination_location) { create(:vaccination_location) }

    subject {
      described_class.create(
        name: 'Phizer',
        series: 'GHI-456',
        doses_number: 2,
        amount: 20,
        min_days_between_doses: 24,
        max_days_between_doses: 42,
        start_date: DateTime.now,
        expiration_date: DateTime.now + 42.days,
        vaccination_location_id: vaccination_location.id,
        admin: admin
      )
    }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:series) }
    it { is_expected.to validate_presence_of(:doses_number) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:min_days_between_doses) }
    it { is_expected.to validate_presence_of(:max_days_between_doses) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:expiration_date) }
    it { is_expected.to validate_presence_of(:vaccination_location_id) }

    it { is_expected.to validate_uniqueness_of(:series).ignoring_case_sensitivity }
  end
end
