# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SuperUsersSecurityController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    SuperUsersSecurityController.new
  end

  let(:super_user) { create(:super_user) }
  let(:email) { super_user.email }
  let(:password) { super_user.password }
  let(:params) {
    {
      email: email,
      password: password
    }
  }

  describe 'POST /super_user/login' do
    let(:response) { post '/super_user/login', params }

    before do
      super_user
    end

    context 'when params are valid' do
      it 'login super_user' do
        response

        expect(last_response.location.split('/').last).to eq 'super_user'
        expect(last_response.status).to eq 302
      end
    end

    context 'when params are not valid' do
      context 'when password is not valid' do
        let(:password) { '000000' }

        it 'returns to login page for super_user' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/super_user/login'
          expect(last_response.status).to eq 302
        end
      end

      context 'when email is not valid' do
        let(:password) { super_user.password }
        let(:email) { 'non_existing@example.com' }

        it 'returns to login page for super user' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/super_user/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /super_user/logout' do
    let(:response) { get '/super_user/logout' }

    before do
      response
    end

    it 'logout super_user and return to login page' do
      expect(last_response.location.split('//').last).to eq 'example.org/super_user/login'
      expect(last_response.status).to eq 302
    end
  end
end
