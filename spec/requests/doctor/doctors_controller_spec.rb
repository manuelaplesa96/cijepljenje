# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DoctorsController' do
  include Rack::Test::Methods

  def app
    DoctorsController.new
  end

  let(:admin) { create(:admin) }
  let(:doctor) { create(:doctor) }
  let(:doctor2) { create(:doctor) }
  let(:id) { doctor.id.to_s }
  let(:session_params) { { 'rack.session' => { 'admin_id' => admin.id } } }

  before do
    admin
    doctor
    doctor2
  end

  describe 'GET /doctor' do
    context 'when doctor is logged_in' do
      let(:response) { get '/doctor', {}, 'rack.session' => { 'doctor_id' => doctor.id } }

      before do
        response
      end

      it 'returns status 302 and redirect' do
        expect(last_response.location.split('//').last).to eq 'example.org/doctor/applications'
        expect(last_response.status).to eq 302
      end
    end

    context 'when doctor is not logged_in' do
      let(:response) { get '/doctor' }

      before do
        response
      end

      it 'returns status 302 and redirect' do
        expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
        expect(last_response.status).to eq 302
      end
    end
  end

  describe 'GET /admin/doctors' do
    context 'when admin is logged in' do
      context 'when try to get all doctors' do
        let(:response) { get '/admin/doctors', {}, session_params }

        before do
          response
        end

        it 'returns view with all doctors' do
          expect(last_response.body.include?('Liječnici')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get all doctors' do
        let(:response) { get '/admin/doctors' }

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

  describe 'GET /admin/doctors/new' do
    context 'when admin is logged in' do
      context 'when try to get new doctor page' do
        let(:response) { get '/admin/doctors/new', {}, session_params }

        before do
          response
        end

        it 'returns view with new doctor page' do
          expect(last_response.body.include?('Dodavanje novog liječnika')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get new doctor page' do
        let(:response) { get '/admin/doctors/new' }

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

  describe 'GET /admin/doctors/:id' do
    context 'when admin is logged in' do
      context 'when id is valid' do
        let(:response) { get '/admin/doctors/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about doctor' do
          expect(last_response.body.include?('Detalji o liječniku')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/admin/doctors/0', {}, session_params  }

        before do
          response
        end
        
        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_DOCTOR[:doctor_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to fetch doctor by id' do
        let(:response) { get '/admin/doctors/' + id }

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

  describe 'PUT /admin/doctors/:id' do
    let(:email) { 'new_doctor@example.com' }
    let(:first_name) { doctor.first_name }
    let(:last_name) { doctor.last_name }
    let(:params) {
      {
        email: email,
        first_name: first_name,
        last_name: last_name
      }
    }
    let(:response) { put '/admin/doctors/' + id, params, session_params }

    context 'when admin is logged in' do
      context 'when change email' do

        before do
          response
        end

        it 'change only email' do
          updated_doctor = Doctor.find(id)

          expect(updated_doctor.email).to eq email
          expect(updated_doctor.first_name).to eq doctor.first_name
          expect(updated_doctor.last_name).to eq doctor.last_name
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
          expect(last_response.status).to eq 302
        end
      end

      context 'when doctor with received email already exist' do
        let(:email) { doctor2.email }

        before do
          response
        end

        it 'does not change email' do
          updated_doctor = Doctor.find(id)

          expect(updated_doctor.email).to eq doctor.email
          expect(updated_doctor.first_name).to eq doctor.first_name
          expect(updated_doctor.last_name).to eq doctor.last_name
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing first name' do
        let(:email) { doctor.email }
        let(:first_name) { 'New' }
        let(:last_name) { doctor.last_name }

        before do
          response
        end

        it 'change only first name' do
          updated_doctor = Doctor.find(id)

          expect(updated_doctor.email).to eq doctor.email
          expect(updated_doctor.first_name).to eq first_name
          expect(updated_doctor.last_name).to eq doctor.last_name
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing last name' do
        let(:email) { doctor.email }
        let(:first_name) { doctor.first_name }
        let(:last_name) { 'New' }

        before do
          response
        end

        it 'change only last name' do
          updated_doctor = Doctor.find(id)

          expect(updated_doctor.email).to eq doctor.email
          expect(updated_doctor.first_name).to eq doctor.first_name
          expect(updated_doctor.last_name).to eq last_name
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
          expect(last_response.status).to eq 302
        end
      end

      context 'when only change first and last name' do
        let(:email) { doctor.email }
        let(:first_name) { 'First' }
        let(:last_name) { 'Last' }
        
        before do
          response
        end

        it 'change first and last name' do
          updated_doctor = Doctor.find(id)

          expect(updated_doctor.email).to eq doctor.email
          expect(updated_doctor.first_name).to eq first_name
          expect(updated_doctor.last_name).to eq last_name
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing all attributes' do
        let(:email) { 'new_doctor2@example.com' }
        let(:first_name) { 'First' }
        let(:last_name) { 'Last' }

        before do
          response
        end

        it 'change all attributes' do
          updated_doctor = Doctor.find(id)

          expect(updated_doctor.email).to eq email
          expect(updated_doctor.first_name).to eq first_name
          expect(updated_doctor.last_name).to eq last_name
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
          expect(last_response.status).to eq 302
        end
      end

      context 'when doctor does not exist' do
        let(:id) { '0' }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_DOCTOR[:doctor_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to change email' do
        let(:email) { 'does_not_change@example.com' }
        let(:response) { put '/admin/doctors/' + id, params }

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

  describe 'POST /admin/doctors' do
    let(:email) { 'create-doctor@example.com' }
    let(:first_name) { 'Create' }
    let(:last_name) { 'Doctor' }
    let(:password) { '123456' }
    let(:params) {
      {
        email: email,
        first_name: first_name,
        last_name: last_name,
        password: password,
        confirm_password: password,
        admin_id: admin.id
      }
    }
    let(:response) { post '/admin/doctors', params, session_params }

    context 'when admin is logged in' do
      context 'when params is valid' do
        before do
          response
        end

        it 'create valid doctor' do
          new_doctor = Doctor.all.last

          expect(new_doctor.email).to eq email
          expect(new_doctor.first_name).to eq first_name
          expect(new_doctor.last_name).to eq last_name
        end

        it 'returns status 302' do
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
            expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when doctor with received email already exists' do
          let(:email) { Doctor.last.email }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when first_name is empty' do
          let(:email) { 'create-doctor2@example.com' }
          let(:first_name) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when last_name is empty' do
          let(:email) { 'create-doctor3@example.com' }
          let(:last_name) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when password is empty' do
          let(:email) { 'create-doctor4@example.com' }
          let(:password) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors/new'
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to create new doctor' do
        let(:response) { post '/admin/doctors', params }

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

  describe 'DELETE /admin/doctors/:id' do
    context 'when admin is logged in' do
      context 'when id is valid' do
        let(:response) { delete '/admin/doctors/' + id, {}, session_params }

        it 'returns status 302 and redirect' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
          expect(last_response.status).to eq 302
        end

        it 'deleted doctor can not be found' do
          response

          expect(Doctor.find_by(id: id)).to eq nil
        end

        it 'remove deleted doctor' do
          expect { response }.to change { Doctor.count }.by(-1)
        end
      end

      context 'when id is invalid' do
        let(:response) { delete '/admin/doctors/0', {}, session_params }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_DOCTOR[:doctor_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to delete doctor' do
        let(:response) { delete '/admin/doctors/' + id }

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
