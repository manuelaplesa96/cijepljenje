# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperUser, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:admin) }
    it { is_expected.to have_many(:applications).dependent(:destroy) }
  end

  describe 'validations are correct' do
    subject {
      described_class.create(
        email: 'test_super_user@example.com',
        password: 'test',
        sector: 'Medical Institution Workers'
      )
    }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password_digest) }
    it { is_expected.to validate_presence_of(:sector) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to allow_value('test1@example.com').for(:email) }
  end
end
