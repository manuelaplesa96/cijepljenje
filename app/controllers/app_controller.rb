# frozen_string_literal: true

require 'sinatra'
require 'sinatra/flash'

class AppController < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  # set folder for templates to ../views, but make the path absolute
  set :views, File.expand_path('../views', __dir__)
  set :method_override, true

  # don't enable logging when running tests
  configure :production, :development do
    enable :logging
  end

  get '/' do
    @message = session[:message]
    session[:message] = nil
    @title = 'Cijepljenje'
    @locations = VaccinationLocation.all
    erb :'main/index'
  end

  helpers do
    def logged_in_admin?
      current_user_admin
    end

    def logged_in_doctor?
      current_user_doctor
    end

    def logged_in_super_user?
      current_user_super_user
    end

    def logged_in_vaccination_worker?
      current_user_vaccination_worker
    end

    def current_user_admin
      @current_user ||= Admin.find(session[:admin_id]) if session[:admin_id]
    end

    def current_user_doctor
      @current_user ||= Doctor.find(session[:doctor_id]) if session[:doctor_id]
    end

    def current_user_super_user
      @current_user ||= SuperUser.find(session[:super_user_id]) if session[:super_user_id]
    end

    def current_user_vaccination_worker
      @current_user ||= VaccinationWorker.find(session[:vaccination_worker_id]) if session[:vaccination_worker_id]
    end

    def redirect_if_not_logged_in?(role)
      case role
      when :admin_id
        redirect to '/admin/login' unless logged_in_admin?
      when :doctor_id
        redirect to '/doctor/login' unless logged_in_doctor?
      when :super_user_id
        redirect to '/super_user/login' unless logged_in_super_user?
      when :vaccination_worker_id
        redirect to '/vaccination_worker/login' unless logged_in_vaccination_worker?
      else
        redirect to '/'
      end
    end

    def no_body_is_logged_in
      !logged_in_admin? && !logged_in_doctor? && !logged_in_super_user? && !logged_in_vaccination_worker?
    end
  end
end
