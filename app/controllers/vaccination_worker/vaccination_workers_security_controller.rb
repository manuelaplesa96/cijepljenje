# frozen_string_literal: true

class VaccinationWorkersSecurityController < AppController
  set :views, File.expand_path('../../views', __dir__)

  get '/vaccination_worker/login' do
    @title = 'Cijepljenje'
    erb :'vaccination_worker/login'
  end

  post '/vaccination_worker/login' do
    begin
      vaccination_worker = VaccinationWorker.find_by(email: params[:email])
    rescue ActiveRecord::RecordNotFound => e
      @error = true
      redirect '/vaccination_worker/login'
    else
      if vaccination_worker&.authenticate(params[:password]) && !logged_in_vaccination_worker?
        session['vaccination_worker_id'] = vaccination_worker.id

        redirect '/vaccination_worker'
      else
        @error = true
        flash[:warning] = SchemeMain::ALERT_MESSAGE[:error_during_login]
        redirect '/vaccination_worker/login'
      end
    end
  end

  get '/vaccination_worker/logout' do
    session[:vaccination_worker_id] = nil
    redirect '/vaccination_worker/login'
  end
end
