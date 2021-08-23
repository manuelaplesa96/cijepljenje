# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'

require 'spec_helper'

RSpec.describe 'VaccinationLocationsController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    VaccinationLocationsController.new
  end

  let(:admin) { create(:admin) }
  let(:vaccination_location) { create(:vaccination_location) }
  let(:vaccination_location2) { create(:vaccination_location) }
  let(:id) { vaccination_location.id.to_s }
  let(:session_params) { { 'rack.session' => { 'admin_id' => admin.id } } }

  before do
    admin
    vaccination_location
    vaccination_location2
  end

  describe 'GET /admin/vaccination_locations' do
    context 'when admin is logged in' do
      context 'when try to get all vaccination_locations' do
        let(:response) { get '/admin/vaccination_locations', {}, session_params }

        before do
          response
        end

        it 'returns view with all vaccination locations' do
          expect(last_response.body.include?('Mjesta cijepljenja')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get all vaccination locations' do
        let(:response) { get '/admin/vaccination_locations' }

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

  describe 'GET /admin/vaccination_locations/new' do
    context 'when admin is logged in' do
      context 'when try to get new vaccination location page' do
        let(:response) { get '/admin/vaccination_locations/new', {}, session_params }

        before do
          response
        end

        it 'returns view with new vaccination location page' do
          expect(last_response.body.include?('Dodavanje novog mjesta cijepljenja')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get new vaccination location page' do
        let(:response) { get '/admin/vaccination_locations/new' }

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

  describe 'GET /admin/vaccination_locations/:id' do
    context 'when admin is logged id' do
      context 'when id is valid' do
        let(:response) { get '/admin/vaccination_locations/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about vaccination location' do
          expect(last_response.body.include?('Detalji o mjestu cijepljenja')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/admin/vaccination_locations/0', {}, session_params }

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
    end

    context 'when admin is not logged in' do
      context 'when try to fetch vaccination location by id' do
        let(:response) { get '/admin/vaccination_locations/' + id }

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

  describe 'POST /admin/vaccination_locations' do
    let(:address) { 'Create Address' }
    let(:city) { 'Create City' }
    let(:county) { 'Create County' }
    let(:params) {
      {
        address: address,
        city: city,
        county: county,
        admin_id: admin.id
      }
    }
    let(:response) { post '/admin/vaccination_locations', params, session_params }

    context 'when admin is logged in' do
      context 'when params is valid' do
        before do
          response
        end

        it 'create valid vaccination location' do
          new_vaccination_location = VaccinationLocation.all.last

          expect(new_vaccination_location.city).to eq city
          expect(new_vaccination_location.address).to eq address
          expect(new_vaccination_location.county).to eq county
        end

        it 'returns status 302 and redirect' do
          expect(last_response.status).to eq 302
        end
      end

      context 'when params is not valid' do
        context 'when address is empty' do
          let(:address) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_locations/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when city name is empty' do
          let(:city) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_locations/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when county name is empty' do
          let(:county) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_locations/new'
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to create vaccination location' do
        let(:response) { post '/admin/vaccination_locations', params }

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

  describe 'DELETE /admin/vaccination_locations/:id' do
    context 'when admin is logged in' do
      context 'when id is valid' do
        let(:response) { delete '/admin/vaccination_locations/' + id, {}, session_params }

        it 'returns status 302 and redirect' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccination_locations'
          expect(last_response.status).to eq 302
        end

        it 'deleted vaccination location can not be found' do
          response

          expect(VaccinationLocation.find_by(id: id)).to eq nil
        end

        it 'remove deleted vaccination location' do
          expect { response }.to change { VaccinationLocation.count }.by(-1)
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/admin/vaccination_locations/0', {}, session_params }

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
    end

    context 'when admin is not logged in'do
      context 'when try to delete vaccination location' do
        let(:response) { delete '/admin/vaccination_locations/' + id }

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
