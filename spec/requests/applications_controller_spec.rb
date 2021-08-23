# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ApplicationsController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    ApplicationsController.new
  end

  let(:doctor) { create(:doctor) }
  let(:super_user) { create(:super_user) }
  let(:location) { create(:vaccination_location, address: 'Relkoviceva 11') }
  let(:application) { create(:application_with_oib, oib: 690_328_096_13) }
  let(:application2) { create(:application_with_oib, oib: 215_903_921_26) }
  let(:application5) { create(:application_with_oib, oib: 466_895_659_19) }
  let(:application8) { create(:application_with_oib, oib: 129_559_635_86) }
  let(:application3) { create(:application_with_mbo) }
  let(:application4) { create(:application_with_mbo) }
  let(:application9) { create(:application_with_mbo, vaccination_location_id: location.id) }
  let(:already_existing_oib_doctor) { application2.oib }
  let(:already_existing_oib_super_user) { application5.oib }
  let(:already_existing_oib) { application8.oib }
  let(:already_existing_mbo) { application3.mbo }
  let(:vaccination_location) { create(:vaccination_location) }
  let(:vaccine) { create(:vaccine) }
  let(:id) { application.id.to_s }
  let(:session_params) { { 'rack.session' => { 'doctor_id' => doctor.id } } }

  let(:vaccination_worker) {
    create(:vaccination_worker, vaccination_location_id: location.id, start_work_time: '08:00', end_work_time: '16:00')
  }

  let(:vaccination_worker2) {
    create(:vaccination_worker, vaccination_location_id: location.id, start_work_time: '12:00', end_work_time: '16:00')
  }

  # belonging application is with same location as worker work place
  # date needs to be changed to todays for specs to pass
  let(:vaccination_time_slot) {
    VaccinationTimeSlot.create(date_and_time: DateTime.new(2021, 8, 12, 10))
  }
  let(:location_and_time_slot) {
    LocationAndTimeSlot.create(vaccination_location: location, vaccination_time_slot: vaccination_time_slot, vaccine: vaccine)
  }

  let(:vaccination_time_slot2) {
    VaccinationTimeSlot.create(date_and_time: DateTime.new(2021, 8, 12, 11))
  }
  let(:location_and_time_slot2) {
    LocationAndTimeSlot.create(vaccination_location: location, vaccination_time_slot: vaccination_time_slot2, vaccine: vaccine)
  }

  let(:vaccination_time_slot3) {
    VaccinationTimeSlot.create(date_and_time: DateTime.new(2021, 8, 12, 10))
  }
  let(:location_and_time_slot3) {
    LocationAndTimeSlot.create(vaccination_location: location, vaccination_time_slot: vaccination_time_slot3, vaccine: vaccine)
  }

  # application have same location as worker
  let(:application6) {
    create(:application_with_mbo, vaccination_location_id: location.id, location_and_time_slot: location_and_time_slot, status: 'rezervirano')
  }
  let(:application7) {
    create(:application_with_mbo, vaccination_location_id: location.id, location_and_time_slot: location_and_time_slot2, status: 'odgodio')
  }

  let(:applications_during_working_hours) { [application6] }

  before do
    doctor
    application3
    application4
    application6
    application7
    location_and_time_slot3
  end

  describe 'GET /doctor/applications' do
    context 'when doctor is logged in' do
      context 'when try to get all applications' do
        let(:response) { get '/doctor/applications', {}, session_params }

        before do
          response
        end

        it 'returns view with all applications' do
          expect(last_response.body.include?('Prijave')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when doctor is not logged in' do
      context 'when try to get all applications' do
        let(:response) { get '/doctor/applications' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /doctor/applications/new' do
    context 'when admin is logged in' do
      context 'when try to get new application page' do
        let(:response) { get '/doctor/applications/new', {}, session_params }

        before do
          response
        end

        it 'returns view with new application page' do
          expect(last_response.body.include?('Prijava na cijepljenje')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get new application page' do
        let(:response) { get '/doctor/applications/new' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /super_user/applications/new' do
    let(:session_params) { { 'rack.session' => { 'super_user_id' => super_user.id } } }

    context 'when admin is logged in' do
      context 'when try to get new application page' do
        let(:response) { get '/super_user/applications/new', {}, session_params }

        before do
          response
        end

        it 'returns view with new application page' do
          expect(last_response.body.include?('Prijava na cijepljenje')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get new application page' do
        let(:response) { get '/super_user/applications/new' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/super_user/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /doctor/applications/:id' do
    let(:id) { application3.id.to_s }

    context 'when doctor si logged in' do
      context 'when id is valid' do
        let(:response) { get '/doctor/applications/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about application' do
          expect(last_response.body.include?('Detalji o prijavi')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/doctor/applications/0', {}, session_params }

        before do
          response
        end
        
        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when doctor is not logged in' do
      context 'when try to get application by id' do
        let(:response) { get '/doctor/applications/' + id }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /doctor/pending/applications' do
    context 'when doctor is logged in' do
      context 'when try to get all pending applications' do
        let(:response) { get '/doctor/pending/applications', {}, session_params }

        before do
          response
        end

        it 'returns all pending applications' do
          expect(last_response.body.include?('Zahtjevi za prijavu')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when doctor is not logged in' do
      context 'when try to get all pending applications' do
        let(:response) { get '/doctor/pending/applications' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'POST /doctor/applications' do
    let(:first_name) { 'Patient' }
    let(:last_name) { 'Testing' }
    let(:birth_date) { Date.new(1996, 10, 12) }
    let(:gender) { 'F' }
    let(:oib) { 216_640_234_32 }
    let(:mbo) { rand(100_000_000..999_999_999) }
    let(:email) { 'patient.testing@example.com' }
    let(:sector) { nil }
    let(:phone_number) { nil }
    let(:chronic_patient) { false }
    let(:vaccination_location_id) { vaccination_location.id }
    let(:author_id) { doctor.id }
    let(:author_type) { doctor.class }
    let(:params) {
      {
        first_name: first_name,
        last_name: last_name,
        birth_date: birth_date,
        gender: gender,
        oib: oib,
        mbo: mbo,
        email: email,
        phone_number: phone_number,
        chronic_patient: chronic_patient,
        vaccination_location_id: vaccination_location_id,
        author_id: author_id,
        author_type: author_type
      }
    }
    let(:response) { post '/doctor/applications', params, session_params }

    context 'when doctor is logged in' do
      context 'when params are valid' do
        context 'when oib is not null' do
          let(:mbo) { '' }

          before do
            response
          end

          it 'create valid application with oib' do
            new_application = Application.all.last

            expect(new_application.first_name).to eq first_name
            expect(new_application.last_name).to eq last_name
            expect(new_application.birth_date).to eq birth_date
            expect(new_application.gender).to eq gender
            expect(new_application.oib).to eq oib
            expect(new_application.email).to eq email
            expect(new_application.phone_number).to eq phone_number
            expect(new_application.chronic_patient).to eq chronic_patient
            expect(new_application.vaccination_location_id).to eq vaccination_location_id
            expect(new_application.status).to eq 'ceka_termin'
          end

          it 'returns status 302' do
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo is not null' do
          let(:oib) { '' }

          before do
            response
          end

          it 'create valid application with mbo' do
            new_application = Application.all.last

            expect(new_application.first_name).to eq first_name
            expect(new_application.last_name).to eq last_name
            expect(new_application.birth_date).to eq birth_date
            expect(new_application.gender).to eq gender
            expect(new_application.mbo).to eq mbo
            expect(new_application.email).to eq email
            expect(new_application.phone_number).to eq phone_number
            expect(new_application.chronic_patient).to eq chronic_patient
            expect(new_application.vaccination_location_id).to eq vaccination_location_id
            expect(new_application.status).to eq 'ceka_termin'
          end

          it 'returns status 302' do
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo and oib is not null' do
          let(:oib) { 688_462_787_14 }

          before do
            response
          end

          it 'create valid application with mbo and oib' do
            new_application = Application.all.last

            expect(new_application.first_name).to eq first_name
            expect(new_application.last_name).to eq last_name
            expect(new_application.birth_date).to eq birth_date
            expect(new_application.gender).to eq gender
            expect(new_application.oib).to eq oib
            expect(new_application.mbo).to eq mbo
            expect(new_application.email).to eq email
            expect(new_application.phone_number).to eq phone_number
            expect(new_application.chronic_patient).to eq chronic_patient
            expect(new_application.vaccination_location_id).to eq vaccination_location_id
            expect(new_application.status).to eq 'ceka_termin'
          end

          it 'returns status 302' do
            expect(last_response.status).to eq 302
          end
        end
      end

      context 'when params is not valid' do
        context 'when oib and mbo is empty' do
          let(:oib) { '' }
          let(:mbo) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when oib is invalid' do
          let(:oib) { 123_123_123_12 }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo is invalid' do
          let(:mbo) { 123_123_123_1 }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when oib already exist' do
          let(:oib) { already_existing_oib_doctor }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo already exist' do
          let(:oib) { 480_658_349_65 }
          let(:mbo) { already_existing_mbo }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when first_name is empty' do
          let(:oib) { 810_538_129_38 }
          let(:first_name) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when last_name is empty' do
          let(:oib) { 928_651_223_73 }
          let(:last_name) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when birth_date is empty' do
          let(:oib) { 213_056_081_08 }
          let(:birth_date) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when gender is empty' do
          let(:oib) { 386_128_090_86 }
          let(:gender) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when email is empty' do
          let(:oib) { 454_137_382_21 }
          let(:email) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when vaccination_location is empty' do
          let(:oib) { 238_031_836_55 }
          let(:vaccination_location_id) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications/new'
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when doctor is not logged in' do
      context 'when try to create application' do
        let(:response) { post '/doctor/applications', params }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'PUT /doctor/applications/:id' do
    let(:id) { application3.id.to_s }
    let(:status) { 'odustao' }
    let(:params) { { status: status } }
    let(:response) { put '/doctor/applications/' + id, params, session_params }

    context 'when doctor is logged in' do
      context "when change status to 'Odustao'" do
        before do
          application3.resolve_chronic_patient
          application3.time_slot_assigned
          application3.save
        end

        it 'change status' do
          response
          updated_application = Application.find_by(id: id)

          expect(updated_application.first_name).to eq application3.first_name
          expect(updated_application.last_name).to eq application3.last_name
          expect(updated_application.birth_date).to eq application3.birth_date
          expect(updated_application.gender).to eq application3.gender
          expect(updated_application.email).to eq application3.email
          expect(updated_application.status).to eq status
          expect(last_response.status).to eq 302
        end
      end

      context "when change status to 'Odgodio'" do
        let(:status) { 'odgodio' }

        before do
          application3.resolve_chronic_patient
          application3.time_slot_assigned
          application3.save
        end

        it 'change status' do
          response
          updated_application = Application.find_by(id: id)

          expect(updated_application.first_name).to eq application3.first_name
          expect(updated_application.last_name).to eq application3.last_name
          expect(updated_application.birth_date).to eq application3.birth_date
          expect(updated_application.gender).to eq application3.gender
          expect(updated_application.email).to eq application3.email
          expect(updated_application.status).to eq status
          expect(last_response.status).to eq 302
        end
      end

      context 'when try to change to other status' do
        let(:status) { 'Test' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications'
          expect(last_response.status).to eq 302
        end
      end

      context 'when send empty status' do
        let(:status) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications'
          expect(last_response.status).to eq 302
        end
      end

      context 'when application does not exsist' do
        let(:id) { '0' }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when doctor is no logged in' do
      context 'when try to change status' do
        let(:status) { 'Odustao' }
        let(:response) { put '/doctor/applications/' + id, params }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'PUT /doctor/applications/vaccination_time_slot/:id' do
    let(:id) { application9.id.to_s }
    let(:vaccination_time_slot_id) { vaccination_time_slot3.id }
    let(:params) { { vaccination_time_slot_id: vaccination_time_slot_id } }
    let(:response) { put '/doctor/applications/vaccination_time_slot/' + id, params, session_params }

    before do
      vaccination_time_slot
    end

    context 'when doctor is logged in' do
      context 'when assign vaccination time slot to application' do
        before do
          application9.resolve_chronic_patient
          application9.save
        end

        it 'assign time slot and change status of application' do
          response
          updated_application = Application.find(id)

          expect(updated_application.location_and_time_slot).to eq location_and_time_slot3
          expect(updated_application.status).to eq 'rezervirano'
        end
      end

      context 'when vaccination time slot does not exist' do
        let(:vaccination_location_id) { '0' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications'
          expect(last_response.status).to eq 302
        end
      end

      context 'when application does not exist' do
        let(:id) { '0' }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when doctor is no logged in' do
      context 'when try to change status' do
        let(:vaccination_time_slot_id) { vaccination_time_slot3.id }
        let(:response) { put '/doctor/applications/vaccination_time_slot/' + id, params }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'PUT /doctor/pending/applications/:id' do
    let(:id) { application3.id.to_s }
    let(:chronic_patient) { true }
    let(:params) { { chronic_patient: chronic_patient } }
    let(:response) { put '/doctor/pending/applications/' + id, params, session_params }

    context 'when doctor is logged in' do
      context 'when accept chronic patient' do
        before do
          response
        end

        it 'accept chronic patient' do
          resolved_application = Application.find_by(id: id)

          expect(resolved_application.chronic_patient).to eq true
          expect(resolved_application.status).to eq 'ceka_termin'
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications'
          expect(last_response.status).to eq 302
        end
      end

      context 'when reject chronic patient' do
        let(:chronic_patient) { false }

        before do
          response
        end

        it 'reject chronic patient' do
          resolved_application = Application.find_by(id: id)

          expect(resolved_application.chronic_patient).to eq false
          expect(resolved_application.status).to eq 'ceka_termin'
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications'
          expect(last_response.status).to eq 302
        end
      end

      context 'when application does not exsist' do
        let(:id) { '0' }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when doctor is no logged in' do
      context 'when try to change status' do
        let(:status) { 'Odustao' }
        let(:response) { put '/doctor/pending/applications/' + id, params }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'POST /super_user/applications' do
    let(:session_params) { { 'rack.session' => { 'super_user_id' => super_user.id } } }

    let(:first_name) { 'Patient' }
    let(:last_name) { 'Testing' }
    let(:birth_date) { Date.new(1996, 10, 12) }
    let(:gender) { 'F' }
    let(:oib) { 472_199_316_67 }
    let(:mbo) { rand(100_000_000..999_999_999) }
    let(:email) { 'patient.testing@example.com' }
    let(:sector) { nil }
    let(:phone_number) { nil }
    let(:chronic_patient) { nil }
    let(:vaccination_location_id) { vaccination_location.id }
    let(:author_id) { super_user.id }
    let(:author_type) { super_user.class }
    let(:params) {
      {
        first_name: first_name,
        last_name: last_name,
        birth_date: birth_date,
        gender: gender,
        oib: oib,
        mbo: mbo,
        email: email,
        sector: super_user.sector,
        chronic_patient: chronic_patient,
        phone_number: phone_number,
        vaccination_location_id: vaccination_location_id,
        author_id: author_id,
        author_type: author_type
      }
    }
    let(:response) { post '/super_user/applications', params, session_params }

    context 'when super_user is logged in' do
      context 'when params are valid' do
        context 'when oib is not null' do
          let(:mbo) { '' }

          before do
            response
          end

          it 'create valid application with oib' do
            new_application = Application.all.last

            expect(new_application.first_name).to eq first_name
            expect(new_application.last_name).to eq last_name
            expect(new_application.birth_date).to eq birth_date
            expect(new_application.gender).to eq gender
            expect(new_application.oib).to eq oib
            expect(new_application.email).to eq email
            expect(new_application.phone_number).to eq phone_number
            expect(new_application.chronic_patient).to eq false
            expect(new_application.vaccination_location_id).to eq vaccination_location_id
            expect(new_application.status).to eq 'ceka_termin'
          end

          it 'returns status 302' do
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo is not null' do
          let(:oib) { '' }

          before do
            response
          end

          it 'create valid application with mbo' do
            new_application = Application.all.last

            expect(new_application.first_name).to eq first_name
            expect(new_application.last_name).to eq last_name
            expect(new_application.birth_date).to eq birth_date
            expect(new_application.gender).to eq gender
            expect(new_application.mbo).to eq mbo
            expect(new_application.email).to eq email
            expect(new_application.phone_number).to eq phone_number
            expect(new_application.chronic_patient).to eq false
            expect(new_application.vaccination_location_id).to eq vaccination_location_id
            expect(new_application.status).to eq 'ceka_termin'
          end

          it 'returns status 302' do
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo and oib is not null' do
          let(:oib) { 789_836_399_60 }

          before do
            response
          end

          it 'create valid application with oib and mbo' do
            new_application = Application.all.last

            expect(new_application.oib).to eq oib
            expect(new_application.mbo).to eq mbo
            expect(new_application.status).to eq 'ceka_termin'
          end

          it 'returns status 302' do
            expect(last_response.status).to eq 302
          end
        end

        context 'when person is chronic patient' do
          let(:oib) { '' }
          let(:chronic_patient) { true }

          before do
            response
          end

          it 'create valid application with oib' do
            new_application = Application.all.last

            expect(new_application.chronic_patient).to eq chronic_patient
            expect(new_application.status).to eq 'u_obradi'
          end

          it 'returns status 302' do
            expect(last_response.status).to eq 302
          end
        end
      end

      context 'when params is not valid' do
        context 'when oib and mbo is empty' do
          let(:oib) { '' }
          let(:mbo) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when oib is invalid' do
          let(:oib) { 123_123_123_12 }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo is invalid' do
          let(:mbo) { 123_123_123_1 }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when oib already exist' do
          let(:oib) { already_existing_oib_super_user }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when mbo already exist' do
          let(:oib) { 680_021_999_39 }
          let(:mbo) { already_existing_mbo }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when first_name is empty' do
          let(:id) { application3.id.to_s }
          let(:oib) { '' }
          let(:first_name) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when last_name is empty' do
          let(:id) { application3.id.to_s }
          let(:oib) { '' }
          let(:last_name) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when birth_date is empty' do
          let(:oib) { 149_433_052_09 }
          let(:birth_date) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when gender is empty' do
          let(:oib) { 669_453_400_96 }
          let(:gender) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when email is empty' do
          let(:oib) { 692_821_772_85 }
          let(:email) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when vaccination_location is empty' do
          let(:oib) { 490_805_804_37 }
          let(:vaccination_location_id) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when author is empty' do
          let(:oib) { 845_774_064_26 }
          let(:author_id) { '' }
          let(:author_type) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when super_user is not logged in' do
      context 'when try to create application' do
        let(:response) { post '/super_user/applications', params }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/super_user/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET to /vaccination_worker/applications' do
    let(:session_params) { { 'rack.session' => { 'vaccination_worker_id' => vaccination_worker.id } } }

    context 'when vaccination_worker is logged in' do
      context 'when try to get all applications during working hours' do
        let(:response) { get '/vaccination_worker/applications', {}, session_params }

        before do
          response
        end

        it 'returns view with all applications' do
          expect(last_response.body.include?('Prijave')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when try to get all applications out of working hours' do
        let(:session_params) { { 'rack.session' => { 'vaccination_worker_id' => vaccination_worker2.id } } }
        let(:response) { get '/vaccination_worker/applications', {}, session_params }

        before do
          response
        end

        it 'returns view with all applications' do
          expect(last_response.body.include?('Prijave')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when vaccination_worker is not logged in' do
      context 'when try to get all applications' do
        let(:response) { get '/vaccination_worker/applications' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /vaccination_worker/applications/:id' do
    let(:session_params) { { 'rack.session' => { 'vaccination_worker_id' => vaccination_worker.id } } }
    let(:id) { application6.id.to_s }

    context 'when vaccination_worker si logged in' do
      context 'when id is valid' do
        let(:response) { get '/vaccination_worker/applications/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about application' do
          expect(last_response.body.include?('Detalji o prijavi')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/vaccination_worker/applications/0', {}, session_params }

        before do
          response
        end
        
        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when application is not during working hours' do
        let(:session_params) { { 'rack.session' => { 'vaccination_worker_id' => vaccination_worker2.id } } }
        let(:response) { get '/vaccination_worker/applications/' + id, {}, session_params }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_APPLICATION[:application_is_not_during_working_hours])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when vaccination_worker is not logged in' do
      context 'when try to get application by id' do
        let(:response) { get '/vaccination_worker/applications/' + id }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'POST /application' do
    let(:first_name) { 'Patient' }
    let(:last_name) { 'Testing' }
    let(:birth_date) { Date.new(1996, 10, 12) }
    let(:gender) { 'F' }
    let(:oib) { 331_909_555_72 }
    let(:mbo) { rand(100_000_000..999_999_999) }
    let(:email) { 'patient.testing@example.com' }
    let(:phone_number) { nil }
    let(:chronic_patient) { nil }
    let(:vaccination_location_id) { vaccination_location.id }
    let(:author_id) { super_user.id }
    let(:author_type) { super_user.class }
    let(:params) {
      {
        first_name: first_name,
        last_name: last_name,
        birth_date: birth_date,
        gender: gender,
        oib: oib,
        mbo: mbo,
        email: email,
        chronic_patient: chronic_patient,
        phone_number: phone_number,
        vaccination_location_id: vaccination_location_id,
        author_id: author_id,
        author_type: author_type
      }
    }
    let(:response) { post '/application', params }

    context 'when params are valid' do
      context 'when oib is not null' do
        let(:mbo) { '' }

        before do
          response
        end

        it 'create valid application with oib' do
          new_application = Application.all.last

          expect(new_application.first_name).to eq first_name
          expect(new_application.last_name).to eq last_name
          expect(new_application.birth_date).to eq birth_date
          expect(new_application.gender).to eq gender
          expect(new_application.oib).to eq oib
          expect(new_application.email).to eq email
          expect(new_application.phone_number).to eq phone_number
          expect(new_application.chronic_patient).to eq false
          expect(new_application.vaccination_location_id).to eq vaccination_location_id
          expect(new_application.status).to eq 'ceka_termin'
        end

        it 'returns status 302' do
          expect(last_response.status).to eq 302
        end
      end

      context 'when mbo is not null' do
        let(:oib) { '' }

        before do
          response
        end

        it 'create valid application with oib' do
          new_application = Application.all.last

          expect(new_application.first_name).to eq first_name
          expect(new_application.last_name).to eq last_name
          expect(new_application.birth_date).to eq birth_date
          expect(new_application.gender).to eq gender
          expect(new_application.mbo).to eq mbo
          expect(new_application.email).to eq email
          expect(new_application.phone_number).to eq phone_number
          expect(new_application.chronic_patient).to eq false
          expect(new_application.vaccination_location_id).to eq vaccination_location_id
          expect(new_application.status).to eq 'ceka_termin'
        end

        it 'returns status 302' do
          expect(last_response.status).to eq 302
        end
      end

      context 'when mbo and oib is not null' do
        let(:oib) { 922_706_180_28 }

        before do
          response
        end

        it 'create valid application with oib' do
          new_application = Application.all.last

          expect(new_application.first_name).to eq first_name
          expect(new_application.last_name).to eq last_name
          expect(new_application.birth_date).to eq birth_date
          expect(new_application.gender).to eq gender
          expect(new_application.oib).to eq oib
          expect(new_application.mbo).to eq mbo
          expect(new_application.email).to eq email
          expect(new_application.phone_number).to eq phone_number
          expect(new_application.chronic_patient).to eq false
          expect(new_application.vaccination_location_id).to eq vaccination_location_id
          expect(new_application.status).to eq 'ceka_termin'
        end

        it 'returns status 302' do
          expect(last_response.status).to eq 302
        end
      end

      context 'when person is chronic patient' do
        let(:oib) { '' }
        let(:chronic_patient) { true }

        before do
          response
        end

        it 'create valid application with oib' do
          new_application = Application.all.last

          expect(new_application.mbo).to eq mbo
          expect(new_application.email).to eq email
          expect(new_application.phone_number).to eq phone_number
          expect(new_application.chronic_patient).to eq chronic_patient
          expect(new_application.vaccination_location_id).to eq vaccination_location_id
          expect(new_application.status).to eq 'u_obradi'
        end

        it 'returns status 302' do
          expect(last_response.status).to eq 302
        end
      end
    end

    context 'when params is not valid' do
      context 'when oib and mbo is empty' do
        let(:oib) { '' }
        let(:mbo) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when oib is invalid' do
        let(:oib) { 987_987_987_98 }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when mbo is invalid' do
        let(:mbo) { 123_123_123_1 }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when oib already exist' do
        let(:oib) { already_existing_oib }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when mbo already exist' do
        let(:oib) { 684_209_404_11 }
        let(:mbo) { already_existing_mbo }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when first_name is empty' do
        let(:id) { application3.id.to_s }
        let(:oib) { '' }
        let(:first_name) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when last_name is empty' do
        let(:id) { application3.id.to_s }
        let(:oib) { '' }
        let(:last_name) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when birth_date is empty' do
        let(:oib) { 149_433_052_09 }
        let(:birth_date) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when gender is empty' do
        let(:oib) { 124_915_658_74 }
        let(:gender) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when email is empty' do
        let(:oib) { 259_741_338_75 }
        let(:email) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end

      context 'when vaccination_location is empty' do
        let(:oib) { 111_103_478_09 }
        let(:vaccination_location_id) { '' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/'
          expect(last_response.status).to eq 302
        end
      end
    end
  end
end
