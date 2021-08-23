# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LocationAndTimeSlot, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:vaccination_location) }
    it { is_expected.to belong_to(:vaccination_time_slot) }
    it { is_expected.to belong_to(:vaccine) }
    it { is_expected.to have_many(:applications).dependent(:destroy) }
  end

  describe 'validations are correct' do
    let(:vaccination_location) { create(:vaccination_location) }
    let(:vaccination_time_slot) { create(:vaccination_time_slot) }
    let(:vaccine) { create(:vaccine) }


    subject {
      described_class.create(
        vaccination_location_id: vaccination_location.id,
        vaccination_time_slot_id: vaccination_time_slot.id,
        vaccine_id: vaccine.id
      )
    }

    it { is_expected.to validate_presence_of(:vaccine_id) }
    it { is_expected.to validate_presence_of(:vaccination_time_slot_id) }
    it { is_expected.to validate_presence_of(:vaccination_location_id) }
  end
end
