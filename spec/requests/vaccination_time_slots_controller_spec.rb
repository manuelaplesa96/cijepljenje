# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'

require 'spec_helper'

RSpec.describe 'VaccinationLocationsController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    VaccinationTimeSlotsController.new
  end

  let(:doctor) { create(:doctor) }
  let(:location) { create(:vaccination_location) }
  let(:vaccine) { create(:vaccine) }
  let(:vaccination_time_slot2) { create(:vaccination_time_slot) }
  let(:vaccination_time_slot3) { create(:vaccination_time_slot) }
  let(:location_and_time_slot) { create(:location_and_time_slot, vaccination_location: location) }
  let(:location_and_time_slot2) { LocationAndTimeSlot.create(vaccination_location: location, vaccination_time_slot: vaccination_time_slot2, vaccine: vaccine) }
  let(:location_and_time_slot3) { LocationAndTimeSlot.create(vaccination_location: location, vaccination_time_slot: vaccination_time_slot3, vaccine: vaccine) }
  let(:application) { create(:application_with_oib, vaccination_location: location, location_and_time_slot: location_and_time_slot) }

  let(:available_time_slots) { [vaccination_time_slot2, vaccination_time_slot3] }
  let(:location_id) { location.id.to_s }
  let(:session_params) { { 'rack.session' => { 'doctor_id' => doctor.id } } }

  before do
    doctor
    location_and_time_slot2
    location_and_time_slot3
    application
  end

  describe 'GET /doctor/vaccination_time_slots/:location' do
    context 'when doctor is logged id' do
      context 'when location exist' do
        let(:response) { get '/doctor/vaccination_time_slots/' + location_id, params, session_params }
        let(:params) {
          {
            application_id: application.id
          }
        }

        before do
          response
        end

        it 'returns page to assign time slot' do
          expect(last_response.body.include?('Dodjela termina za zahtjev')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when location does not exist' do
        let(:response) { get '/doctor/vaccination_time_slots/0', {}, session_params }

        before do
          response
        end
        
        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_VACCINATION_LOCATION[:vaccination_location_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when application does not exist' do
        let(:params) {
          {
            application_id: 0
          }
        }
        let(:response) { get '/doctor/vaccination_time_slots/' + location_id, params, session_params }

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
      context 'when try to get all available vaccination time slot for specific location' do
        let(:response) { get '/doctor/vaccination_time_slots/' + location_id }

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
end
