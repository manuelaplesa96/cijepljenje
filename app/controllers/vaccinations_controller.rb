# frozen_string_literal: true

class VaccinationsController < AppController
  include ControllerHelper

  set :views, File.expand_path('../views', __dir__)

  get '/vaccination_worker/vaccinations' do
    redirect_if_not_logged_in?(:vaccination_worker_id)

    @title = 'Cijepljenje'
    @vaccinations = Vaccination.where(vaccination_worker_id: session[:vaccination_worker_id])
    
    erb :'vaccination/index'
  end

  get '/vaccination_worker/vaccinations/:id' do
    redirect_if_not_logged_in?(:vaccination_worker_id)

    @title = 'Cijepljenje'

    @vaccination = Vaccination.find_by(id: params[:id], vaccination_worker_id: session[:vaccination_worker_id])
    @message = SchemeMain::ERROR_MESSAGES_VACCINATION[:vaccination_does_not_exist] if @vaccination.nil?
    return erb :'errors/404_vaccination_worker' if @message

    @vaccines = Vaccine.where(name: @vaccination.vaccine.name)

    erb :'vaccination/show'
  end

  get '/vaccination_worker/vaccinations/new/:id' do
    redirect_if_not_logged_in?(:vaccination_worker_id)
    
    @title = 'Cijepljenje'
    @application = Application.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] if @application.nil?
    return erb :'/errors/404_vaccination_worker' if @message

    if application_have_vaccine(@application)
      @vaccines = Vaccine.where(name: application_have_vaccine(@application).name)
    else
      @vaccines = Vaccine.all
    end
    @dose_number = find_dose_if_exist(@application)

    erb :'vaccination/new'
  end

  post '/vaccination_worker/vaccinations' do
    redirect_if_not_logged_in?(:vaccination_worker_id)

    application = Application.find_by(id: params[:application_id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] if application.nil?
    return erb :'errors/404_vaccination_worker' if @message

    if dose_number.to_i.zero?
      flash[:danger] = SchemeMain::ERROR_MESSAGES_VACCINATION[:wrong_vaccine_dose]
      redirect '/vaccination_worker/vaccinations/new/' + params[:application_id]
    end

    begin
      vaccination = Vaccination.create!(
        application: application,
        vaccine: vaccine,
        vaccination_time_slot: vaccination_time_slot,
        vaccination_worker: vaccination_worker,
        dose_number: dose_number
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/vaccination_worker/vaccinations/new/' + params[:application_id]
    else
      # change status depending on dose number
      application = change_status(application)
      application.save
      flash[:success] = SchemeMain::ALERT_MESSAGE[:successfull_vaccination]
      redirect '/vaccination_worker/applications'
    end
  end

  put '/vaccination_worker/vaccinations/:id' do
    redirect_if_not_logged_in?(:vaccination_worker_id)

    vaccination = Vaccination.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_VACCINATION[:vaccination_does_not_exist] if vaccination.nil?
    return erb :'errors/404_vaccination_worker' if @message

    @message = SchemeMain::ERROR_MESSAGES_VACCINE[:vaccine_does_not_exist] if vaccine.nil?
    return erb :'errors/404_vaccination_worker' if @message

    vaccination.vaccine = vaccine
    vaccination.save
    redirect '/vaccination_worker/vaccinations'
  end

  private

  def application_have_vaccine(application)
    vaccination = Vaccination.find_by(application_id: application.id)
    return vaccination.vaccine unless vaccination.nil?
  end

  def find_dose_if_exist(application)
    vaccination = Vaccination.where(application_id: application.id).last
    if vaccination
      return vaccination.dose_number 
    else
      return 0
    end
  end

  def vaccination_worker
    @vaccination_worker ||= VaccinationWorker.find(session[:vaccination_worker_id])
  end

  def vaccine
    @vaccine ||= Vaccine.find_by(series: series)
  end

  def series
    @series ||= params[:vaccine_series]
  end

  def dose_number
    if vaccine.nil? || vaccine.doses_number < params[:dose_number].to_i
       @dose_number = 0
    else
      @dose_number = params[:dose_number]
    end
  end

  def vaccination_time_slot
    application = Application.find_by(id: params[:application_id])

    @vaccination_time_slot ||= VaccinationTimeSlot.find(application.location_and_time_slot.vaccination_time_slot_id)
  end

  def change_status(application)
    dose = dose_number.to_i
    case dose
      when 1
        application.vaccination_with_dose_1
      when 2
        application.vaccination_with_dose_2
      when 3
        application.vaccination_with_dose_3
    end
    application
  end
end
