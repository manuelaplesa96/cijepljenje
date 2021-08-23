# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AdminController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    AdminsController.new
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

  describe 'GET /admin' do
    context 'when admin is logged_in' do
      let(:response) { get '/admin', {}, 'rack.session' => { 'admin_id' => admin.id } }

      before do
        response
      end

      it 'returns status 302 and redirect' do
        expect(last_response.location.split('//').last).to eq 'example.org/admin/doctors'
        expect(last_response.status).to eq 302
      end
    end

    context 'when admin is not logged_in' do
      let(:response) { get '/admin' }

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
