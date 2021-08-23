# frozen_string_literal: true

class VaccinationTimeSlotsController < AppController
  include ControllerHelper

  set :views, File.expand_path('../views', __dir__)

  get '/doctor/vaccination_time_slots/:location_id' do
    redirect_if_not_logged_in?(:doctor_id)

    @title = 'Cijepljenje'
    @message = SchemeMain::ERROR_MESSAGES_VACCINATION_LOCATION[:vaccination_location_does_not_exist] if VaccinationLocation.find_by(id: params[:location_id]).nil?
    return erb :'/errors/404_doctor' if @message

    @available_time_slots = fetch_available_vaccination_time_slots(params[:location_id])
    @application = Application.find_by(id: params[:application_id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] if @application.nil?
    return erb :'/errors/404_doctor' if @message

    erb :'/application/doctor_side/vaccination_time_slots'
  end
end
