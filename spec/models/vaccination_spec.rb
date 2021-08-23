# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vaccination, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:application) }
    it { is_expected.to belong_to(:vaccine) }
    it { is_expected.to belong_to(:vaccination_time_slot) }
    it { is_expected.to belong_to(:vaccination_worker) }
  end

  describe 'validations are correct' do
    let(:vaccination_worker) { create(:vaccination_worker) }
    let(:vaccination_time_slot) { create(:vaccination_time_slot) }
    let(:vaccine) { create(:vaccine) }
    let(:application) { create(:application_with_mbo) }

    subject {
      described_class.create(
        application: application,
        vaccination_time_slot: vaccination_time_slot,
        vaccine: vaccine,
        vaccination_worker: vaccination_worker,
        dose_number: 1
      )
    }

    it { is_expected.to validate_presence_of(:application_id) }
    it { is_expected.to validate_presence_of(:vaccination_time_slot_id) }
    it { is_expected.to validate_presence_of(:vaccine_id) }
    it { is_expected.to validate_presence_of(:vaccination_worker_id) }
    it { is_expected.to validate_presence_of(:dose_number) }
  end
end
