# frozen_string_literal: true

class VaccinationWorkersController < AppController
  include ControllerHelper

  set :views, File.expand_path('../../views', __dir__)

  get '/vaccination_worker' do
    redirect_if_not_logged_in?(:vaccination_worker_id)

    @title = 'Cijepljenje'
    
    redirect '/vaccination_worker/applications'
  end

  get '/admin/vaccination_workers' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @vaccination_workers = VaccinationWorker.all
    @locations = VaccinationLocation.all
    
    erb :'/vaccination_worker/index'
  end

  get '/admin/vaccination_workers/new' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @locations = VaccinationLocation.all
    @start_work_times = work_times(7, 12)
    @end_work_times = work_times(12,20)

    erb :'/vaccination_worker/new'
  end

  get '/admin/vaccination_workers/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @vaccination_worker = VaccinationWorker.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_VACCINATION_WORKER[:vaccination_worker_does_not_exist] if @vaccination_worker.nil?
    return erb :'/errors/404_admin' if @message

    @locations = VaccinationLocation.all
    @location = @locations.find(@vaccination_worker.vaccination_location_id)
    @start_work_times = work_times(7, 12)
    @end_work_times = work_times(12,20)

    erb :'vaccination_worker/show'
  end

  put '/admin/vaccination_workers/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @message = nil
    vaccination_worker = VaccinationWorker.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_VACCINATION_WORKER[:vaccination_worker_does_not_exist] if vaccination_worker.nil?
    return erb :'errors/404_admin' if @message

    vaccination_worker.vaccination_location_id = vaccination_location_id
    vaccination_worker.start_work_time = start_work_time
    vaccination_worker.end_work_time = end_work_time
    vaccination_worker.time_zone = time_zone
    
    if vaccination_worker.email != email
      @message = email_already_exist
      vaccination_worker.email = email unless @message
    end

    vaccination_worker.save
    redirect '/admin/vaccination_workers'
  end

  post '/admin/vaccination_workers' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    begin
      vaccination_worker = VaccinationWorker.create!(
        email: email,
        password: password,
        start_work_time: start_work_time,
        end_work_time: end_work_time,
        time_zone: time_zone,
        vaccination_location_id: vaccination_location_id,
        admin_id: params[:admin_id]
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/admin/vaccination_workers/new'
    else
      vaccination_worker.to_json
      redirect '/admin/vaccination_workers'
    end
  end

  private

  def work_times(start_time, end_time)
    times = []
    for i in start_time..end_time do
      if i < 10
        times << '0' + i.to_s + ':00' 
      else
        times << i.to_s + ':00'
      end
    end
    times
  end

  def email
    @email ||= params[:email]
  end

  def password
    @password ||= params[:password]
  end

  def vaccination_location_id
    @vaccination_location_id ||= params[:vaccination_location_id]
  end

  def start_work_time
    @start_work_time ||= params[:start_work_time]
  end

  def end_work_time
    @end_work_time ||= params[:end_work_time]
  end

  def time_zone
    @time_zone ||= params[:time_zone]
  end

  def email_already_exist
    vaccination_worker = VaccinationWorker.find_by(email: email)
    return SchemeMain::ERROR_MESSAGES_VACCINATION_WORKER[:email_already_exist] if vaccination_worker
  end
end
