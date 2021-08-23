# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'

require 'spec_helper'

RSpec.describe 'VaccinesController' do
  include Rack::Test::Methods

  def app
    VaccinesController.new
  end

  let(:admin) { create(:admin) }
  let(:vaccine) { create(:vaccine) }
  let(:vaccine2) { create(:vaccine) }
  let(:vaccination_location) { create(:vaccination_location) }
  let(:id) { vaccine.id.to_s }
  let(:session_params) { { 'rack.session' => { 'admin_id' => admin.id } } }

  before do
    admin
    vaccine
    vaccine2
  end

  describe 'GET /admin/vaccines' do
    context 'when admin is logged in' do
      context 'when try to get all vaccines' do
        let(:response) { get '/admin/vaccines', {}, session_params }

        before do
          response
        end

        it 'returns view with all vaccines' do
          expect(last_response.body.include?('Cjepiva')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get all vaccines' do
        let(:response) { get '/admin/vaccines' }

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

  describe 'GET /admin/vaccines/new' do
    context 'when admin is logged in' do
      context 'when try to get new vaccine page' do
        let(:response) { get '/admin/vaccines/new', {}, session_params }

        before do
          response
        end

        it 'returns view with new vaccine page' do
          expect(last_response.body.include?('Dodavanje novog cjepiva')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get new vaccine page' do
        let(:response) { get '/admin/vaccines/new' }

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

  describe 'GET /admin/vaccines/:id' do
    context 'when admin si logged in' do
      context 'when id is valid' do
        let(:response) { get '/admin/vaccines/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about vaccine' do
          expect(last_response.body.include?('Detalji o cjepivu')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/admin/vaccines/0', {}, session_params }

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
    end

    context 'when admin is not logged in' do
      context 'when try to fetch vaccine by id' do
        let(:response) { get '/admin/vaccines/' + id }

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

  describe 'POST /admin/vaccines' do
    let(:name) { 'Test Vaccine' }
    let(:series) { 'MNO-1' }
    let(:doses_number) { 3 }
    let(:amount) { 30 }
    let(:min_days_between_doses) { 20 }
    let(:max_days_between_doses) { 40 }
    let(:start_date) { DateTime.now }
    let(:expiration_date) { DateTime.now + 42 }
    let(:vaccination_location_id) { vaccination_location.id }
    let(:params) {
      {
        name: name,
        series: series,
        doses_number: doses_number,
        amount: amount,
        min_days_between_doses: min_days_between_doses,
        max_days_between_doses: max_days_between_doses,
        start_date: start_date,
        expiration_date: expiration_date,
        vaccination_location_id: vaccination_location_id,
        admin_id: admin.id
      }
    }
    let(:response) { post '/admin/vaccines', params, session_params }

    context 'when admin is logged in' do
      context 'when params is valid' do
        before do
          response
        end

        it 'create valid vaccine' do
          new_vaccine = Vaccine.all.last

          expect(new_vaccine.name).to eq name
          expect(new_vaccine.series).to eq series
          expect(new_vaccine.amount).to eq amount
          expect(new_vaccine.doses_number).to eq doses_number
          expect(new_vaccine.min_days_between_doses).to eq min_days_between_doses
          expect(new_vaccine.max_days_between_doses).to eq max_days_between_doses
          expect(new_vaccine.vaccination_location_id).to eq vaccination_location_id
        end
      end

      context 'when params is not valid' do
        context 'when name is empty' do
          let(:series) { 'MNO-2' }
          let(:name) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when series is empty' do
          let(:series) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when vaccine with received series already exists' do
          let(:series) { Vaccine.last.series }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when doses_number is empty' do
          let(:series) { 'MNO-5' }
          let(:doses_number) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when amount is empty' do
          let(:series) { 'MNO-6' }
          let(:amount) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when min_days_between_doses is empty' do
          let(:series) { 'MNO-7' }
          let(:min_days_between_doses) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when max_days_between_doses is empty' do
          let(:series) { 'MNO-8' }
          let(:max_days_between_doses) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when start_date is empty' do
          let(:series) { 'MNO-9' }
          let(:start_date) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when vaccination_location_id is empty' do
          let(:series) { 'MNO-11' }
          let(:vaccination_location_id) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines/new'
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to create vaccine' do
        let(:response) { post '/admin/vaccines', params }

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

  describe 'DELETE /admin/vaccines/:id' do
    context 'when  is logged in' do
      context 'when id is valid' do
        let(:response) { delete '/admin/vaccines/' + id, {}, session_params }

        it 'returns status 302 and redirect' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/admin/vaccines'
          expect(last_response.status).to eq 302
        end

        it 'deleted vaccine can not be found' do
          response

          expect(Vaccine.find_by(id: id)).to eq nil
        end

        it 'remove deleted vaccine' do
          expect { response }.to change { Vaccine.count }.by(-1)
        end
      end

      context 'when id is invalid' do
        let(:response) { delete '/admin/vaccines/0', {}, session_params }

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
    end

    context 'when admin is not logged in' do
      context 'when try to delete vaccine' do
        let(:response) { delete '/admin/vaccines/' + id }

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
