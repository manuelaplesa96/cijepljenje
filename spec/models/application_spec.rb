# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Application, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:vaccination_location) }
    it { is_expected.to belong_to(:location_and_time_slot) }
    it { is_expected.to have_many(:vaccinations) }
  end

  describe 'validations are correct' do
    let(:doctor) { create(:doctor) }
    let(:vaccination_location) { create(:vaccination_location) }
    let(:location_and_time_slot) { create(:location_and_time_slot) }

    context 'person is applied with oib' do
      subject {
        described_class.create(
          first_name: 'Person',
          last_name: 'Surname',
          birth_date: Date.new(1996, 10, 12),
          gender: 'F',
          oib: rand(100_000_000_00..999_999_999_99),
          email: 'person@example.com',
          chronic_patient: false,
          status: 'u obradi',
          vaccination_location: vaccination_location,
          location_and_time_slot: location_and_time_slot,
          author: doctor
        )
      }

      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_presence_of(:birth_date) }
      it { is_expected.to validate_presence_of(:gender) }
      it { is_expected.to validate_presence_of(:oib) }
      it { is_expected.to validate_presence_of(:mbo).allow_nil }
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_presence_of(:status) }
      it { is_expected.to validate_presence_of(:vaccination_location) }
      it { is_expected.to validate_uniqueness_of(:oib) }
      it { is_expected.to validate_uniqueness_of(:mbo) }
    end

    context 'person is applied with mbo' do
      subject {
        described_class.create(
          first_name: 'Person',
          last_name: 'Surname',
          birth_date: Date.new(1996, 10, 12),
          gender: 'F',
          mbo: rand(100_000_000..999_999_999),
          email: 'person@example.com',
          chronic_patient: false,
          status: 'u obradi',
          vaccination_location: vaccination_location,
          location_and_time_slot: location_and_time_slot,
          author: doctor
        )
      }

      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_presence_of(:birth_date) }
      it { is_expected.to validate_presence_of(:gender) }
      it { is_expected.to validate_presence_of(:oib).allow_nil }
      it { is_expected.to validate_presence_of(:mbo) }
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_presence_of(:status) }
      it { is_expected.to validate_presence_of(:vaccination_location) }
      it { is_expected.to validate_uniqueness_of(:oib) }
      it { is_expected.to validate_uniqueness_of(:mbo) }
    end
  end

  describe 'state machine' do
    let(:application) { create(:application_with_mbo) }
    let(:status) { 'u_obradi' }

    it "initial status is 'u obradi'" do
      expect(application.u_obradi?).to be true
    end

    context 'when application has status "u obradi"' do
      it 'changes from "u obradi" to "ceka_termin" on resolve_chronic_patient' do
        expect { application.resolve_chronic_patient }.to change(application, :status).from(status).to('ceka_termin')
      end

      it 'changes from "u obradi" to "odustao" on cancel' do
        expect { application.cancel }.to change(application, :status).from(status).to('odustao')
      end
    end

    context 'when application has status "ceka_termin"' do
      let(:status) { 'ceka_termin' }

      before do
        application.resolve_chronic_patient
      end

      it 'changes from "ceka_termin" to "rezervirano" on time_slot_assigned' do
        expect { application.time_slot_assigned }.to change(application, :status).from(status).to('rezervirano')
      end

      it 'changes from "ceka_termin" to "odustao" on cancel' do
        expect { application.cancel }.to change(application, :status).from(status).to('odustao')
      end
    end

    context 'when application has status "rezervirano"' do
      let(:status) { 'rezervirano' }

      before do
        application.resolve_chronic_patient
        application.time_slot_assigned
      end

      it 'changes from "rezervirano" to "doza_1" on vaccination_with_dose_1' do
        expect { application.vaccination_with_dose_1 }.to change(application, :status).from(status).to('doza_1')
      end

      it 'changes from "rezervirano" to "doza_2" on vaccination_with_dose_2' do
        expect { application.vaccination_with_dose_2 }.to change(application, :status).from(status).to('doza_2')
      end

      it 'changes from "rezervirano" to "doza_3" on vaccination_with_dose_3' do
        expect { application.vaccination_with_dose_3 }.to change(application, :status).from(status).to('doza_3')
      end

      it 'changes from "rezervirano" to "odgodio" on postpone' do
        expect { application.postpone }.to change(application, :status).from(status).to('odgodio')
      end

      it 'changes from "rezervirano" to "odustao" on cancel' do
        expect { application.cancel }.to change(application, :status).from(status).to('odustao')
      end
    end

    context 'when application has status "doza_1"' do
      let(:status) { 'doza_1' }

      before do
        application.resolve_chronic_patient
        application.time_slot_assigned
        application.vaccination_with_dose_1
      end

      it 'changes from "doza_1" to "odustao" on cancel' do
        expect { application.cancel }.to change(application, :status).from(status).to('odustao')
      end

      it 'changes from "doza_1" to "ceka_termin" on needs_to_continue_vaccination' do
        expect { application.needs_to_continue_vaccination }.to change(application, :status).from(status).to('ceka_termin')
      end

      it 'changes from "doza_1" to "gotovo" on finished' do
        expect { application.finished }.to change(application, :status).from(status).to('gotovo')
      end
    end

    context 'when application has status "doza_2"' do
      let(:status) { 'doza_2' }

      before do
        application.resolve_chronic_patient
        application.time_slot_assigned
        application.vaccination_with_dose_2
      end

      it 'changes from "doza_2" to "odustao" on cancel' do
        expect { application.cancel }.to change(application, :status).from(status).to('odustao')
      end

      it 'changes from "doza_2" to "ceka_termin" on needs_to_continue_vaccination' do
        expect { application.needs_to_continue_vaccination }.to change(application, :status).from(status).to('ceka_termin')
      end

      it 'changes from "doza_2" to "gotovo" on finished' do
        expect { application.finished }.to change(application, :status).from(status).to('gotovo')
      end
    end

    context 'when application has status "doza_3"' do
      let(:status) { 'doza_3' }

      before do
        application.resolve_chronic_patient
        application.time_slot_assigned
        application.vaccination_with_dose_3
      end

      it 'changes from "doza_3" to "odustao" on cancel' do
        expect { application.cancel }.to change(application, :status).from(status).to('odustao')
      end

      it 'changes from "doza_3" to "ceka_termin" on needs_to_continue_vaccination' do
        expect { application.needs_to_continue_vaccination }.to change(application, :status).from(status).to('ceka_termin')
      end

      it 'changes from "doza_3" to "gotovo" on finished' do
        expect { application.finished }.to change(application, :status).from(status).to('gotovo')
      end
    end

    context 'when application has status "odgodio"' do
      let(:status) { 'odgodio' }

      before do
        application.resolve_chronic_patient
        application.time_slot_assigned
        application.postpone
      end

      it 'changes from "odgodio" to "ceka_termin" on cancel' do
        expect { application.needs_to_continue_vaccination }.to change(application, :status).from(status).to('ceka_termin')
      end
    end
  end
end
