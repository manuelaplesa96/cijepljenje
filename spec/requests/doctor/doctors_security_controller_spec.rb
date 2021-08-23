# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DoctorsSecurityController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    DoctorsSecurityController.new
  end

  let(:doctor) { create(:doctor) }
  let(:email) { doctor.email }
  let(:password) { doctor.password }
  let(:params) {
    {
      email: email,
      password: password
    }
  }

  describe 'POST /doctor/login' do
    let(:response) { post '/doctor/login', params }

    before do
      doctor
    end

    context 'when params are valid' do
      it 'login doctor' do
        response

        expect(last_response.location.split('/').last).to eq 'doctor'
        expect(last_response.status).to eq 302
      end
    end

    context 'when params are not valid' do
      context 'when password is not valid' do
        let(:password) { '000000' }

        it 'returns to login page for doctor' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end

      context 'when email is not valid' do
        let(:password) { doctor.password }
        let(:email) { 'non_existing@example.com' }

        it 'returns to login page for doctor' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /doctor/logout' do
    let(:response) { get '/doctor/logout' }

    before do
      response
    end

    it 'logout doctor and return to login page' do
      expect(last_response.location.split('//').last).to eq 'example.org/doctor/login'
      expect(last_response.status).to eq 302
    end
  end
end
