# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:doctors).dependent(:destroy) }
    it { is_expected.to have_many(:super_users).dependent(:destroy) }
    it { is_expected.to have_many(:vaccination_locations).dependent(:destroy) }
    it { is_expected.to have_many(:vaccination_workers).dependent(:destroy) }
    it { is_expected.to have_many(:vaccines).dependent(:destroy) }
  end

  describe 'validations are correct' do
    subject { described_class.create(email: 'test_admin@example.com', password: 'test') }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password_digest) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to allow_value('test1@example.com').for(:email) }
  end
end
