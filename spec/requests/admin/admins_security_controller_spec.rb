# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AdminsSecurityController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    AdminsSecurityController.new
  end

  let(:admin) { create(:admin) }
  let(:email) { admin.email }
  let(:password) { admin.password }
  let(:params) {
    {
      email: email,
      password: password
    }
  }

  describe 'POST /admin/login' do
    let(:response) { post '/admin/login', params }

    before do
      admin
    end

    context 'when params are valid' do
      it 'login admin' do
        response

        expect(last_response.location.split('/').last).to eq 'admin'
        expect(last_response.status).to eq 302
      end
    end

    context 'when params are not valid' do
      context 'when password is not valid' do
        let(:password) { '000000' }

        it 'returns to login page for admin' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
          expect(last_response.status).to eq 302
        end
      end

      context 'when email is not valid' do
        let(:password) { admin.password }
        let(:email) { 'non_existing@example.com' }

        it 'returns to login page for admin' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
          expect(last_response.status).to eq 302
        end
      end
    end
  end

  describe 'GET /admin/logout' do
    let(:response) { get '/admin/logout' }

    before do
      response
    end

    it 'logout admin and return to login page' do
      expect(last_response.location.split('//').last).to eq 'example.org/admin/login'
      expect(last_response.status).to eq 302
    end
  end
end
