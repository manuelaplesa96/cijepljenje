# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'VaccinationWorkersSecurityController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    VaccinationWorkersSecurityController.new
  end

  let(:vaccination_worker) { create(:vaccination_worker) }
  let(:email) { vaccination_worker.email }
  let(:password) { vaccination_worker.password }
  let(:params) {
    {
      email: email,
      password: password
    }
  }

  describe 'POST /vaccination_worker/login' do
    let(:response) { post '/vaccination_worker/login', params }

    before do
      vaccination_worker
    end

    context 'when params are valid' do
      it 'login vaccination_worker' do
        response

        expect(last_response.location.split('/').last).to eq 'vaccination_worker'
        expect(last_response.status).to eq 302
      end
    end

    context 'when params are not valid' do
      context 'when password is not valid' do
        let(:password) { '000000' }

        it 'returns to login page for vaccination_worker' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/login'
          expect(last_response.status).to eq 302
        end
      end

      context 'when email is not valid' do
        let(:password) { vaccination_worker.password }
        let(:email) { 'non_existing@example.com' }

        it 'returns to login page for vaccination worker' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /vaccination_worker/logout' do
    let(:response) { get '/vaccination_worker/logout' }

    before do
      response
    end

    it 'logout vaccination_worker and return to login page' do
      expect(last_response.location.split('//').last).to eq 'example.org/vaccination_worker/login'
      expect(last_response.status).to eq 302
    end
  end
end
