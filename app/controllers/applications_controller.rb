# frozen_string_literal: true

class ApplicationsController < AppController
  include ControllerHelper

  set :views, File.expand_path('../views', __dir__)

  get '/doctor/applications' do
    redirect_if_not_logged_in?(:doctor_id)

    @title = 'Cijepljenje'
    @applications = Application.all
    @vaccinations = Vaccination.all

    erb :'/application/doctor_side/index'
  end

  get '/doctor/applications/new' do
    redirect_if_not_logged_in?(:doctor_id)

    @title = 'Cijepljenje'
    @locations = VaccinationLocation.all 

    erb :'/application/doctor_side/new'
  end

  get '/super_user/applications/new' do
    redirect_if_not_logged_in?(:super_user_id)

    @title = 'Cijepljenje'
    @locations = VaccinationLocation.all
    @super_user = SuperUser.find(session[:super_user_id])

    erb :'/application/super_user_side/new'
  end

  get '/doctor/applications/:id' do
    redirect_if_not_logged_in?(:doctor_id)

    @title = 'Cijepljenje'
    @application = Application.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] unless @application

    return erb :'errors/404_doctor' if @message

    @locations = VaccinationLocation.all
    @statuses = [Application.statuses[:odustao], Application.statuses[:odgodio]]

    erb :'application/doctor_side/show'
  end

  get '/doctor/pending/applications' do
    redirect_if_not_logged_in?(:doctor_id)

    @title = 'Cijepljenje'
    @pending_applications = Application.where(status: Application.statuses[:u_obradi])

    erb :'/application/doctor_side/pending'
  end

  post '/doctor/applications' do
    redirect_if_not_logged_in?(:doctor_id)
    
    @title = 'Cijepljenje'

    unless check_params.nil?
      flash[:danger] = check_params 
      redirect "/doctor/applications/new"
    end
    
    begin
      application = Application.create!(
        first_name: first_name,
        last_name: last_name,
        birth_date: birth_date,
        gender: gender,
        oib: oib,
        mbo: mbo,
        email: email,
        sector: sector,
        phone_number: phone_number,
        chronic_patient: chronic_patient,
        status: Application.statuses[:u_obradi],
        vaccination_location_id: params[:vaccination_location_id],
        author_id: session[:doctor_id],
        reference: reference
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/doctor/applications/new'
    else
      application.resolve_chronic_patient
      application.save
      send_email_with_application_id(application.email, message_body(application))
      application.to_json
      flash[:success] = SchemeMain::ALERT_MESSAGE[:successfull]

      redirect '/doctor/applications'
    end
  end

  put '/doctor/applications/:id' do
    redirect_if_not_logged_in?(:doctor_id)

    @message = check_status

    if @message
      redirect '/doctor/applications'
    end

    application = Application.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] if application.nil?
    return erb :'errors/404_doctor' if @message

    @message = application_can_not_be_postponed(application) unless application_can_not_be_postponed(application).nil?
    if @message
      redirect '/doctor/applications'
    end

    case params[:status]
    when Application.statuses[:odustao]
      application.cancel
    when Application.statuses[:odgodio]
      application.postpone
    end

    application.first_name = first_name unless params[:first_name].nil?
    application.last_name = last_name unless params[:last_name].nil?
    application.birth_date = birth_date unless params[:birth_date].nil?
    application.gender = gender unless params[:gender].nil? 
    application.email = email unless params[:email].nil?
    application.phone_number = phone_number unless params[:phone_number].nil?
    application.vaccination_location_id = vaccination_location_id unless params[:vaccination_location_id].nil?

    application.save

    redirect '/doctor/applications'
  end

  put '/doctor/applications/vaccination_time_slot/:id' do
    redirect_if_not_logged_in?(:doctor_id)

    application = Application.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] if application.nil?
    return erb :'errors/404_doctor' if @message

    vaccination_time_slot_id = params[:vaccination_time_slot_id]

    redirect '/doctor/applications' if vaccination_time_slot_id.nil? || application.status.gsub('_', ' ') != Application.statuses[:ceka_termin]
    location_and_time_slot = LocationAndTimeSlot.find_by(vaccination_location_id: application.vaccination_location.id, vaccination_time_slot_id: vaccination_time_slot_id)

    application.location_and_time_slot_id = location_and_time_slot.id
    application.time_slot_assigned
    application.save

    date_and_time = date_and_time_format(location_and_time_slot.vaccination_time_slot.date_and_time)
    address = application.vaccination_location.address
    city = application.vaccination_location.city

    message_body = "<h2>Termin cijepljenja za zahtjev ##{application.reference}</h2><p>Vrijeme cijepljenja: #{date_and_time} <br>Adresa mjesta cijepljenja: #{address}, #{city}</p>"
    send_email_with_application_id(application.email, message_body)
    redirect '/doctor/applications'
  end

  put '/doctor/pending/applications/:id' do
    redirect_if_not_logged_in?(:doctor_id)

    application = Application.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] if application.nil?
    return erb :'errors/404_doctor' if @message

    application.chronic_patient = params[:chronic_patient]
    application.resolve_chronic_patient
    application.save
    send_email_with_application_id(application.email, message_body(application))
    application.to_json
    flash[:success] = SchemeMain::ALERT_MESSAGE[:pending_resolve]
    redirect '/doctor/applications'
  end

  post '/super_user/applications' do
    redirect_if_not_logged_in?(:super_user_id)

    unless check_params.nil?
      flash[:danger] = check_params 
      redirect "/super_user/applications/new"
    end

    begin
      application = Application.create!(
        first_name: first_name,
        last_name: last_name,
        birth_date: birth_date,
        gender: gender,
        oib: oib,
        mbo: mbo,
        email: email,
        sector: sector,
        phone_number: phone_number,
        chronic_patient: chronic_patient,
        status: application_status(),
        vaccination_location_id: params[:vaccination_location_id],
        author_id: params[:author_id],
        author_type: params[:author_type],
        reference: reference
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/super_user/applications/new'
    else
      flash[:success] = SchemeMain::ALERT_MESSAGE[:successfull]
      if application_status() == Application.statuses[:ceka_termin]
        send_email_with_application_id(application.email, message_body(application))
      end
      redirect 'super_user/applications/new'
    end
  end

  get '/vaccination_worker/applications' do
    redirect_if_not_logged_in?(:vaccination_worker_id)

    @title = 'Cijepljenje'

    @applications = fetch_applications_during_working_hours_of_vaccination_worker
    @locations = VaccinationLocation.all
    @location_and_time_slots = LocationAndTimeSlot.all
    @vaccinations = Vaccination.all

    erb :'/application/vaccination_worker_side/index'
  end

  get '/vaccination_worker/applications/:id' do
    redirect_if_not_logged_in?(:vaccination_worker_id)

    @title = 'Cijepljenje'

    @application = Application.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist] if @application.nil?
    return erb :'errors/404_vaccination_worker' if @message

    apps = fetch_applications_during_working_hours_of_vaccination_worker
    @locations = VaccinationLocation.all
    @location_and_time_slots = LocationAndTimeSlot.all
    @vaccinations = Vaccination.all

    return erb :'application/vaccination_worker_side/show' if apps.find(@application.id) && !apps.empty?

    @message = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_is_not_during_working_hours]
    erb :'errors/404_vaccination_worker'
  end

  post '/application' do
    unless check_params.nil?
      flash[:danger] = check_params 
      redirect "/"
    end

    begin
      application = Application.create!(
        first_name: first_name,
        last_name: last_name,
        birth_date: birth_date,
        gender: gender,
        oib: oib,
        mbo: mbo,
        email: email,
        chronic_patient: chronic_patient,
        phone_number: phone_number,
        status: application_status(),
        vaccination_location_id: params[:vaccination_location_id],
        reference: reference
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect "/"
    else
      application.to_json
      flash[:success] = SchemeMain::ALERT_MESSAGE[:successfull]
      if application_status() == Application.statuses[:ceka_termin]
        send_email_with_application_id(application.email, message_body(application))
      end
      redirect "/"
    end
  end

  private

  def application_can_not_be_postponed(application)
    vaccination = Vaccination.find_by(application_id: application.id)
    return unless vaccination

    # it can be postpone if 7 days from now is not greater than max das between doses
    vaccine = vaccination.vaccine

    # date of last vaccination
    vaccination_date = vaccination.vaccination_time_slot.date_and_time
    # date of next vaccination
    current_time_slot = application.location_and_time_slot.vaccination_time_slot.date_and_time
    #date of postpone vaccination
    new_time_slot = current_time_slot + 7.days
    max_days_between_doses = vaccine.max_days_between_doses

    until max_days_between_doses.zero?
      vaccination_date += 1.day
      max_days_between_doses -= 1
    end

    # if new date is greater than last vaccination date + max days between doses than 
    # we know that vaccination can not be postpone and person can only cancel for good
    # so we return invalid status message
    SchemeMain::ERROR_MESSAGES_APPLICATION[:invalid_status] if new_time_slot > vaccination_date
  end

  def check_status
    return if params[:status].empty?

    return SchemeMain::ERROR_MESSAGES_APPLICATION[:invalid_status] unless [Application.statuses[:odustao], Application.statuses[:odgodio]].include?(params[:status])
  end

  def check_params
    message = check_oib(params[:oib].to_s) unless oib.empty? && !mbo.empty?
    message ||= check_mbo(params[:mbo].to_s) unless mbo.empty? && !oib.empty?
    message
  end

  def first_name
    @first_name ||= params[:first_name]
  end

  def last_name
    @last_name ||= params[:last_name]
  end

  def birth_date
    @birth_date ||= params[:birth_date].to_datetime
  end

  def gender
    @gender ||= params[:gender]
  end

  def oib
    @oib ||= params[:oib]
  end

  def mbo
    @mbo ||= params[:mbo]
  end

  def email
    @email ||= params[:email]
  end

  def sector
    @sector ||= params[:sector]
  end

  def vaccination_location_id
    @vaccination_location_id ||= params[:vaccination_location_id]
  end

  def phone_number
    @phone_number ||= params[:phone_number]
  end

  def chronic_patient
    return @chronic_patient ||= false if params[:chronic_patient].nil? || !params[:chronic_patient]

    @chronic_patient ||= params[:chronic_patient]
  end

  def application_status
    return Application.statuses[:u_obradi] if !params[:chronic_patient].nil?
    Application.statuses[:ceka_termin]
  end

  def reference
    reference = first_name + '-' + last_name + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
  end

  def message_body(application)
    "<h2>Potvrda cijepljenja</h2><p>Vaš zahtjev za cijeljenje je prihvaćen. <br>Identifikacijski broj zahtjeva je: #{application.reference}</p><strong>Ovaj broj nije javan!</strong>"
  end
end
