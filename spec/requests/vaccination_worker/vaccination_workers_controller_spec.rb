# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'

require 'spec_helper'

RSpec.describe 'VaccinationWorkersController' do
  include Rack::Test::Methods

  def app
    VaccinationWorkersController.new
  end

  let(:admin) { create(:admin) }
  let(:vaccination_worker) { create(:vaccination_worker) }
  let(:vaccination_worker2) { create(:vaccination_worker) }
  let(:id) { vaccination_worker.id.to_s }
  let(:vaccination_location_id) { vaccination_worker.vaccination_location_id }
  let(:start_work_time) { vaccination_worker.start_work_time }
  let(:end_work_time) { vaccination_worker.end_work_time }
  let(:time_zone) { vaccination_worker.time_zone }
  let(:session_params) { { 'rack.session' => { 'admin_id' => admin.id } } }

  before do
    admin
    vaccination_worker
    vaccination_worker2
  end

  describe 'GET /vaccination_worker' do
    context 'when vaccination worker is logged_in' do
      let(:response) { get '/vaccination_worker', {}, 'rack.session' => { 'vaccination_worker_id' => vaccination_worker.id } }

      before do
        response
      end

      it 'returns status 302 and redirect' do
        expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/applications'
        expect(last_response.status).to eq 302
      end
    end

    context 'when vaccination worker is not logged_in' do
      let(:response) { get '/vaccination_worker' }

      before do
        response
      end

      it 'returns status 302 and redirect' do
        expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/login'
        expect(last_response.status).to eq 302
      end
    end
  end

  describe 'GET /admin/vaccination_workers' do
    context 'when admin is logged in' do
      context 'when try to get all vaccination workers' do
        let(:response) { get '/admin/vaccination_workers', {}, session_params }

        before do
          response
        end

        it 'returns view with all vaccination worker' do
          expect(last_response.body.include?('Cjepitelji')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get all vaccination workers' do
        let(:response) { get '/admin/vaccination_workers' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /admin/vaccination_workers/new' do
    context 'when admin is logged in' do
      context 'when try to get new vaccination worker page' do
        let(:response) { get '/admin/vaccination_workers/new', {}, session_params }

        before do
          response
        end

        it 'returns view with new vaccination worker page' do
          expect(last_response.body.include?('Dodavanje novog cjepitelja')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get new vaccination worker page' do
        let(:response) { get '/admin/vaccination_workers/new' }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /admin/vaccination_workers/:id' do
    context 'when admin is logged in' do
      context 'when id is valid' do
        let(:response) { get '/admin/vaccination_workers/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about vaccination worker' do
          expect(last_response.body.include?('Detalji o cjepitelju')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/admin/vaccination_workers/0', {}, session_params }

        before do
          response
        end
        
        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_VACCINATION_WORKER[:vaccination_worker_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to fetch vaccination worker by id' do
        let(:response) { get '/admin/vaccination_workers/' + id }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'PUT /admin/vaccination_workers/:id' do
    let(:email) { 'new_vaccination_worker@example.com' }
    let(:params) {
      {
        email: email,
        vaccination_location_id: vaccination_location_id,
        start_work_time: start_work_time,
        end_work_time: end_work_time,
        time_zone: time_zone
      }
    }
    let(:response) { put '/admin/vaccination_workers/' + id, params, session_params }

    context 'when admin is logged in' do
      context 'when change email' do

        before do
          response
        end

        it 'change only email' do
          updated_vaccination_worker = VaccinationWorker.find(id)

          expect(updated_vaccination_worker.email).to eq email
          expect(updated_vaccination_worker.vaccination_location_id).to eq vaccination_worker.vaccination_location_id
          expect(updated_vaccination_worker.start_work_time).to eq vaccination_worker.start_work_time
          expect(updated_vaccination_worker.end_work_time).to eq vaccination_worker.end_work_time
          expect(updated_vaccination_worker.time_zone).to eq vaccination_worker.time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers'
          expect(last_response.status).to eq 302
        end
      end

      context 'when vaccination_worker with received email already exist' do
        let(:email) { vaccination_worker2.email }

        before do
          response
        end

        it 'does not change email' do
          updated_vaccination_worker = VaccinationWorker.find(id)

          expect(updated_vaccination_worker.email).to eq vaccination_worker.email
          expect(updated_vaccination_worker.vaccination_location_id).to eq vaccination_worker.vaccination_location_id
          expect(updated_vaccination_worker.start_work_time).to eq vaccination_worker.start_work_time
          expect(updated_vaccination_worker.end_work_time).to eq vaccination_worker.end_work_time
          expect(updated_vaccination_worker.time_zone).to eq vaccination_worker.time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing vaccination location' do
        let(:email) { vaccination_worker.email }
        let(:vaccination_location) { create(:vaccination_location) }
        let(:vaccination_location_id) { vaccination_location.id }

        before do
          response
        end

        it 'change only vaccination location' do
          updated_vaccination_worker = VaccinationWorker.find(id)

          expect(updated_vaccination_worker.email).to eq vaccination_worker.email
          expect(updated_vaccination_worker.vaccination_location_id).to eq vaccination_location_id
          expect(updated_vaccination_worker.start_work_time).to eq vaccination_worker.start_work_time
          expect(updated_vaccination_worker.end_work_time).to eq vaccination_worker.end_work_time
          expect(updated_vaccination_worker.time_zone).to eq vaccination_worker.time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing start work time' do
        let(:email) { vaccination_worker.email }
        let(:start_work_time) { '06:00' }

        before do
          response
        end

        it 'change only start work time' do
          updated_vaccination_worker = VaccinationWorker.find(id)

          expect(updated_vaccination_worker.email).to eq vaccination_worker.email
          expect(updated_vaccination_worker.vaccination_location_id).to eq vaccination_worker.vaccination_location_id
          expect(updated_vaccination_worker.start_work_time).to eq start_work_time
          expect(updated_vaccination_worker.end_work_time).to eq vaccination_worker.end_work_time
          expect(updated_vaccination_worker.time_zone).to eq vaccination_worker.time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing end work time' do
        let(:email) { vaccination_worker.email }
        let(:end_work_time) { '16:00' }

        before do
          response
        end

        it 'change only end work time' do
          updated_vaccination_worker = VaccinationWorker.find(id)

          expect(updated_vaccination_worker.email).to eq vaccination_worker.email
          expect(updated_vaccination_worker.vaccination_location_id).to eq vaccination_worker.vaccination_location_id
          expect(updated_vaccination_worker.start_work_time).to eq vaccination_worker.start_work_time
          expect(updated_vaccination_worker.end_work_time).to eq end_work_time
          expect(updated_vaccination_worker.time_zone).to eq vaccination_worker.time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing time zone' do
        let(:email) { vaccination_worker.email }
        let(:time_zone) { 'London' }

        before do
          response
        end

        it 'change only time zone' do
          updated_vaccination_worker = VaccinationWorker.find(id)

          expect(updated_vaccination_worker.email).to eq vaccination_worker.email
          expect(updated_vaccination_worker.vaccination_location_id).to eq vaccination_worker.vaccination_location_id
          expect(updated_vaccination_worker.start_work_time).to eq vaccination_worker.start_work_time
          expect(updated_vaccination_worker.end_work_time).to eq vaccination_worker.end_work_time
          expect(updated_vaccination_worker.time_zone).to eq time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing all attributes' do
        let(:email) { 'new_vaccination_worker2@example.com' }
        let(:vaccination_location) { create(:vaccination_location) }
        let(:vaccination_location_id) { vaccination_location.id }
        let(:start_work_time) { '05:00' }
        let(:end_work_time) { '10:00' }
        let(:time_zone) { 'New York' }

        before do
          response
        end

        it 'change all attributes' do
          updated_vaccination_worker = VaccinationWorker.find(id)

          expect(updated_vaccination_worker.email).to eq email
          expect(updated_vaccination_worker.vaccination_location_id).to eq vaccination_location_id
          expect(updated_vaccination_worker.start_work_time).to eq start_work_time
          expect(updated_vaccination_worker.end_work_time).to eq end_work_time
          expect(updated_vaccination_worker.time_zone).to eq time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers'
          expect(last_response.status).to eq 302
        end
      end

      context 'when vaccination_worker does not exsist' do
        let(:id) { '0' }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_VACCINATION_WORKER[:vaccination_worker_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to change email' do
        let(:email) { 'does_not_change@example.com' }
        let(:response) { put '/admin/vaccination_workers/' + id, params }


        before do
          response
        end
        
        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'POST /admin/vaccination_workers' do
    let(:email) { 'create-doctor@example.com' }
    let(:password) { '123456' }
    let(:params) {
      {
        email: email,
        password: password,
        confirm_password: password,
        start_work_time: start_work_time,
        end_work_time: end_work_time,
        time_zone: time_zone,
        vaccination_location_id: vaccination_location_id,
        admin_id: admin.id
      }
    }
    let(:response) { post '/admin/vaccination_workers', params, session_params }

    context 'when admin is logged in' do
      context 'when params is valid' do
        before do
          response
        end

        it 'create valid vaccination worker' do
          new_vaccination_worker = VaccinationWorker.all.last

          expect(new_vaccination_worker.email).to eq email
          expect(new_vaccination_worker.vaccination_location_id).to eq vaccination_location_id
          expect(new_vaccination_worker.start_work_time).to eq start_work_time
          expect(new_vaccination_worker.end_work_time).to eq end_work_time
          expect(new_vaccination_worker.time_zone).to eq time_zone
        end

        it 'returns status 302 and redirect' do
          expect(last_response.status).to eq 302
        end
      end

      context 'when params is not valid' do
        context 'when email is empty' do
          let(:email) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when vaccination worker with received email already exists' do
          let(:email) { VaccinationWorker.last.email }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when vaccination location is empty' do
          let(:email) { 'create-doctor1@example.com' }
          let(:vaccination_location_id) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when start_work_time is empty' do
          let(:email) { 'create-doctor2@example.com' }
          let(:start_work_time) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when end_work_time is empty' do
          let(:email) { 'create-doctor3@example.com' }
          let(:end_work_time) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when time_zone is empty' do
          let(:email) { 'create-doctor4@example.com' }
          let(:time_zone) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when password is empty' do
          let(:email) { 'create-doctor5@example.com' }
          let(:password) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_workers/new'
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to create new vaccination worker' do
        let(:response) { post '/admin/vaccination_workers', params }

        before do
          response
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end
end
