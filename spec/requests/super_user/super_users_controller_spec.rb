# frozen_string_literal: true

ENV['SINATRA_ENV'] = 'test'

require 'spec_helper'

RSpec.describe 'SuperUsersController' do
  include Rack::Test::Methods
  include AppHelper

  def app
    SuperUsersController.new
  end

  let(:admin) { create(:admin) }
  let(:super_user) { create(:super_user) }
  let(:super_user2) { create(:super_user) }
  let(:id) { super_user.id.to_s }
  let(:session_params) { { 'rack.session' => { 'admin_id' => admin.id } } }

  before do
    admin
    super_user
    super_user2
  end

  describe 'GET /super_user' do
    context 'when super_user is logged_in' do
      let(:response) { get '/super_user', {}, 'rack.session' => { 'super_user_id' => super_user.id } }

      before do
        response
      end

      it 'returns status 302 and redirect' do
        expect(last_response.location.split('//').last).to eq 'example.org/super_user/applications/new'
        expect(last_response.status).to eq 302
      end
    end

    context 'when super_user is not logged_in' do
      let(:response) { get '/super_user' }

      before do
        response
      end

      it 'returns status 302 and redirect' do
        expect(last_response.location.split('//').last).to eq 'example.org/super_user/login'
        expect(last_response.status).to eq 302
      end
    end
  end

  describe 'GET /admin/super_users' do
    context 'when admin is logged in' do
      context 'when try to get all superusers' do
        let(:response) { get '/admin/super_users', {}, session_params }

        before do
          response
        end

        it 'returns view with all superusers' do
          expect(last_response.body.include?('Predstavnici prioritetnih skupina')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get all superusers' do
        let(:response) { get '/admin/super_users' }

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

  describe 'GET /admin/super_users/new' do
    context 'when admin is logged in' do
      context 'when try to get new superuser page' do
        let(:response) { get '/admin/super_users/new', {}, session_params }

        before do
          response
        end

        it 'returns view with new superuser page' do
          expect(last_response.body.include?('Dodavanje novog predstavnika prioriteta')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to get new superuser page' do
        let(:response) { get '/admin/super_users/new' }

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

  describe 'GET /admin/super_users/:id' do
    context 'when admin is logged in' do
      context 'when id is valid' do
        let(:response) { get '/admin/super_users/' + id, {}, session_params }

        before do
          response
        end

        it 'returns details about superuser' do
          expect(last_response.body.include?('Detalji o predstavniku prioriteta')).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end

      context 'when id is invalid' do
        let(:response) { get '/admin/super_users/0', {}, session_params }

        before do
          response
        end
        
        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_SUPER_USER[:super_user_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to fetch superuser by id' do
        let(:response) { get '/admin/super_users/' + id }

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

  describe 'PUT /admin/super_users/:id' do
    let(:email) { 'new_super_user@example.com' }
    let(:sector) { super_user.sector }
    let(:params) {
      {
        email: email,
        sector: sector
      }
    }
    let(:response) { put '/admin/super_users/' + id, params, session_params }

    context 'when admin is logged in' do
      context 'when change email' do

        before do
          response
        end

        it 'change only email' do
          updated_super_user = SuperUser.find(id)

          expect(updated_super_user.email).to eq email
          expect(updated_super_user.sector).to eq super_user.sector
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users'
          expect(last_response.status).to eq 302
        end
      end

      context 'when super_user with received email already exist' do
        let(:email) { super_user2.email}

        before do
          response
        end

        it 'does not change email' do
          updated_super_user = SuperUser.find(id)

          expect(updated_super_user.email).to eq super_user.email
          expect(updated_super_user.sector).to eq super_user.sector
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing sector' do
        let(:email) { super_user.email }
        let(:sector) { 'New Sector' }

        before do
          response
        end

        it 'change only sector' do
          updated_super_user = SuperUser.find(id)

          expect(updated_super_user.email).to eq super_user.email
          expect(updated_super_user.sector).to eq sector
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users'
          expect(last_response.status).to eq 302
        end
      end

      context 'when changing all attributes' do
        let(:email) { 'new_super_user2@example.com' }
        let(:sector) { 'Test sector' }

        before do
          response
        end

        it 'change only sector' do
          updated_super_user = SuperUser.find(id)

          expect(updated_super_user.email).to eq email
          expect(updated_super_user.sector).to eq sector
        end

        it 'returns status 302 and redirect' do
          expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users'
          expect(last_response.status).to eq 302
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to change email' do
        let(:email) { 'does_not_change@example.com' }
        let(:response) { put '/admin/super_users/' + id, params }

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

  describe 'POST /admin/super_users' do
    let(:email) { 'create-super-user@example.com' }
    let(:sector) { 'Create Sector' }
    let(:password) { '123456' }
    let(:params) {
      {
        email: email,
        sector: sector,
        password: password,
        confirm_password: password,
        admin_id: admin.id
      }
    }
    let(:response) { post '/admin/super_users', params, session_params }

    context 'when admin is logged in' do
      context 'when params is valid' do
        before do
          response
        end

        it 'create valid superuser' do
          new_super_user = SuperUser.all.last

          expect(new_super_user.email).to eq email
          expect(new_super_user.sector).to eq sector
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
            expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when superuser with received email already exist' do
          let(:email) { SuperUser.last.email }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when sector is empty' do
          let(:email) { 'create-super-user1@example.com' }
          let(:sector) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users/new'
            expect(last_response.status).to eq 302
          end
        end

        context 'when password is empty' do
          let(:email) { 'create-super-user2@example.com' }
          let(:password) { '' }

          before do
            response
          end

          it 'returns status 302 and redirect' do
            expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users/new'
            expect(last_response.status).to eq 302
          end
        end
      end
    end

    context 'when admin is not logged in' do
      context 'when try to create new superuser' do
        let(:response) { post '/admin/super_users', params }

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

  describe 'DELETE /admin/super_users/:id' do
    context 'when admin is logged in' do
      context 'when id is valid' do
        let(:response) { delete '/admin/super_users/' + id, {}, session_params }

        it 'returns status 302 and redirect' do
          response

          expect(last_response.location.split('//').last).to eq 'example.org/admin/super_users'
          expect(last_response.status).to eq 302
        end

        it 'deleted superuser can not be found' do
          response

          expect(SuperUser.find_by(id: id)).to eq nil
        end

        it 'remove deleted superuser' do
          expect { response }.to change { SuperUser.count }.by(-1)
        end
      end

      context 'when id is invalid' do
        let(:response) { delete '/admin/super_users/0', {}, session_params }

        before do
          response
        end

        it 'returns 404 error page' do
          expect(last_response.body.include?(SchemeMain::ERROR_MESSAGES_SUPER_USER[:super_user_does_not_exist])).to eq true
        end

        it 'returns status 200 OK' do
          expect(last_response.status).to eq 200
        end
      end
    end

    context 'when admin is now logged in' do
      context 'when try to delete superuser' do
        let(:response) { delete '/admin/super_users/' + id }

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
