# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Doctor, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:admin) }
    it { is_expected.to have_many(:applications).dependent(:destroy) }
  end

  describe 'validations are correct' do
    subject {
      described_class.create(
        email: 'test_doctor@example.com',
        password: 'test',
        first_name: 'Test',
        last_name: 'Testing'
      )
    }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password_digest) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to allow_value('test1@example.com').for(:email) }
  end
end
