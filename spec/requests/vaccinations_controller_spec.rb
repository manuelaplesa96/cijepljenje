# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'

require 'spec_helper'

RSpec.describe 'VaccinationsController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    VaccinationsController.new
  end

  let(:application) { create(:application_with_mbo) }
  let(:location) { create(:vaccination_location, address: 'Relkoviceva 11') }
  let(:vaccination_worker) {
    create(:vaccination_worker, vaccination_location_id: location.id, start_work_time: '08:00', end_work_time: '16:00')
  }

  let(:vaccination_worker2) {
    create(:vaccination_worker, vaccination_location_id: location.id, start_work_time: '12:00', end_work_time: '16:00')
  }

  let(:vaccination) {
    create(:vaccination, vaccination_worker_id: vaccination_worker.id)
  }
  let(:id) { vaccination.id.to_s }
  let(:vaccination2) {
    create(:vaccination, vaccination_worker_id: vaccination_worker.id)
  }
  let(:vaccination3) { create(:vaccination) }
  let(:vaccinations_created_by_vaccination_worker) { [vaccination, vaccination2] }
  let(:session_params) {
    { 'rack.session' => { 'vaccination_worker_id' => vaccination_worker.id } }
  }

  before do
    vaccination_worker
    vaccination
    vaccination2
    vaccination3
  end

  describe 'GET /vaccination_worker/vaccinations' do
    context 'when vaccination_worker is logged in' do
      let(:response) { get '/vaccination_worker/vaccinations', {}, session_params }

      context 'when try to get all vaccinations created by vaccination worker' do
        
        before do
          response
        end

        it 'returns view with all vaccinations' do
          expect(last_response.body.include?('Do sad obavljena cijepljenja')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when try to get vaccination for vaccine worker that did not create one' do
        let(:session_params) {
          { 'rack.session' => { 'vaccination_worker_id' => vaccination_worker2.id } }
        }

        before do
          response
        end

        it 'returns view with vaccinations' do
          expect(last_response.body.include?('Do sad obavljena cijepljenja')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when vaccination_worker is not logged in' do
      context 'when try to get all vaccinations' do
        let(:response) { get '/vaccination_worker/vaccinations' }

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

  describe 'GET /vaccination_worker/vaccinations/new/:id' do
    context 'when vaccination_worker is logged in' do
      context 'when application does exist' do
        context 'when try to get new vaccination page' do
          let(:response) { get '/vaccination_worker/vaccinations/new/' + application.id.to_s, {}, session_params }

          before do
            response
          end

          it 'returns view with new vaccination page' do
            expect(last_response.body.include?('Novo cijepljenje')).to eq true
          end

          it 'returns status 200 OK' do
            expect(last_response.status).to eq 200
          end
        end
      end

      context 'when application does not exist' do
        context 'when try to get new vaccination page' do
          let(:response) { get '/vaccination_worker/vaccinations/new/0', {}, session_params }

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
    end

    context 'when vaccination_worker is not logged in' do
      context 'when try to get new vaccination page' do
        let(:response) { get '/vaccination_worker/vaccinations/new/' + application.id.to_s }

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

  describe 'GET /vaccination_worker/vaccinations/:id' do
    context 'when vaccination_worker si logged in' do
      context 'when id is valid' do
        let(:response) { get '/vaccination_worker/vaccinations/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about vaccination' do
          expect(last_response.body.include?('Detalji o cijepljenju')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/vaccination_worker/vaccinations/0', {}, session_params }

        before do
          response
        end
        
        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_VACCINATION[:vaccination_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id belongs to vaccination of another vaccination worker' do
        let(:id) { vaccination3.id.to_s }
        let(:response) { get '/vaccination_worker/vaccinations/' + id, {}, session_params }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_VACCINATION[:vaccination_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when vaccination_worker is not logged in' do
      context 'when try to fetch vaccine by id' do
        let(:response) { get '/vaccination_worker/vaccinations/' + id }

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

  describe 'POST /vaccination_worker/vaccinations' do
    let(:vaccination_time_slot) {
      VaccinationTimeSlot.create(date_and_time: DateTime.new(2021, 5, 2, 10))
    }
    let(:location_and_time_slot) { create(:location_and_time_slot, vaccination_time_slot: vaccination_time_slot) }
    let(:application) {
      create(:application_with_mbo, status: Application.statuses[:rezervirano], location_and_time_slot_id: location_and_time_slot.id)
    }
    let(:vaccine) { create(:vaccine) }
    let(:dose_number) { 1 }
    let(:vaccine_series) { vaccine.series }

    let(:params) {
      {
        application_id: application.id,
        vaccine_series: vaccine_series,
        dose_number: dose_number
      }
    }
    let(:response) { post '/vaccination_worker/vaccinations', params, session_params }

    context 'when vaccination_worker is logged in' do
      context 'when params is valid' do
        before do
          response
        end
        it 'create valid vaccination' do
          new_vaccination = Vaccination.all.last

          expect(new_vaccination.application_id).to eq application.id
          expect(new_vaccination.vaccine_id).to eq vaccine.id
          expect(new_vaccination.dose_number).to eq dose_number
        end

        it 'change status' do
          expect(Vaccination.last.application.status).to eq 'doza_1'
        end
      end

      context 'when params is not valid' do
        context 'when vaccine series does not exist' do
          let(:vaccine_series) { '123-1' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/vaccinations/new/' + application.id.to_s
            expect(last_response.status).to eq 302
          end
        end

        context 'when vaccine series is empty' do
          let(:vaccine_series) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/vaccinations/new/' + application.id.to_s
            expect(last_response.status).to eq 302
          end
        end

        context 'when dose number is empty' do
          let(:dose_number) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/vaccinations/new/' + application.id.to_s
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when vaccination_worker is not logged in' do
      context 'when try to create vaccine' do
        let(:response) { post '/vaccination_worker/vaccinations', params }

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

  describe 'PUT /vaccination_worker/vaccinations/:id' do
    let(:id) { vaccination.id.to_s }
    let(:vaccine) { vaccination.vaccine }
    let(:vaccine_series) { vaccine.series }
    let(:params) {
      {
        vaccine_series: vaccine_series
      }
    }
    let(:response) { put '/vaccination_worker/vaccinations/' + id, params, session_params }

    context 'when vaccination_worker is logged in' do
      context 'when change vaccine' do
        let(:dose_number) { vaccination.dose_number }

        before do
          response
        end

        it 'change only vaccine series' do
          updated_vaccination = Vaccination.find(id)

          expect(updated_vaccination.vaccine).to eq vaccine
          expect(updated_vaccination.dose_number).to eq vaccination.dose_number 
        end
      end

      context 'when changing vaccine series to non existing' do
        let(:vaccine_series) { '123-4' }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_VACCINE[:vaccine_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when vaccination does not exsist' do
        let(:id) { '0' }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_VACCINATION[:vaccination_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when vaccination_worker is not logged in' do
      context 'when try to change email' do
        let(:email) { 'does_not_change@example.com' }
        let(:response) { put '/vaccination_worker/vaccinations/' + id, params }

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
end
