# frozen_string_literal: true

class DoctorsSecurityController < AppController
  set :views, File.expand_path('../../views', __dir__)

  get '/doctor/login' do
    @title = 'Cijepljenje'
    erb :'doctor/login'
  end

  post '/doctor/login' do
    begin
      doctor = Doctor.find_by(email: params[:email])
    rescue ActiveRecord::RecordNotFound => e
      e.message
    else
      if doctor&.authenticate(params[:password]) && !logged_in_doctor?
        session['doctor_id'] = doctor.id

        redirect '/doctor'
      else
        @error = true
        flash[:warning] = SchemeMain::ALERT_MESSAGE[:error_during_login]
        redirect '/doctor/login'
      end
    end
  end

  get '/doctor/logout' do
    session[:doctor_id] = nil
    redirect '/doctor/login'
  end
end
