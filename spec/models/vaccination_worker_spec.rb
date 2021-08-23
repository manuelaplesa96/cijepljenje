# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VaccinationWorker, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:admin) }
    it { is_expected.to have_many(:vaccinations) }
  end

  describe 'validations are correct' do
    let(:admin) { create(:admin) }
    let(:vaccination_location) { create(:vaccination_location) }

    subject {
      described_class.create(
        email: 'test_vaccination_worker@example.com',
        password: 'test',
        start_work_time: '08:00',
        end_work_time: '13:00',
        vaccination_location_id: vaccination_location.id,
        admin: admin
      )
    }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password_digest) }
    it { is_expected.to validate_presence_of(:start_work_time) }
    it { is_expected.to validate_presence_of(:end_work_time) }
    it { is_expected.to validate_presence_of(:time_zone) }
    it { is_expected.to validate_presence_of(:vaccination_location_id) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to allow_value('test1@example.com').for(:email) }
  end
end
