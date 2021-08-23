# frozen_string_literal: true

class VaccinesController < AppController
  include ControllerHelper

  set :views, File.expand_path('../views', __dir__)

  get '/admin/vaccines' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @vaccines = Vaccine.all
    @locations = VaccinationLocation.all
    
    erb :'/vaccine/index'
  end

  get '/admin/vaccines/new' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @locations = VaccinationLocation.all

    erb :'/vaccine/new'
  end

  get '/admin/vaccines/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @vaccine = Vaccine.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_VACCINE[:vaccine_does_not_exist] if @vaccine.nil?
    return erb :'/errors/404_admin' if @message

    @location = VaccinationLocation.find(@vaccine.vaccination_location_id)
    
    erb :'vaccine/show'
  end

  post '/admin/vaccines' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    begin
      vaccine = Vaccine.create!(
        name: name,
        series: series,
        doses_number: doses_number,
        amount: amount,
        min_days_between_doses: min_days_between_doses,
        max_days_between_doses: max_days_between_doses,
        start_date: start_date,
        expiration_date: expiration_date,
        vaccination_location_id: vaccination_location_id,
        admin_id: session[:admin_id]
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/admin/vaccines/new'
    else
      vaccine.to_json
      redirect '/admin/vaccines'
    end
  end

  delete '/admin/vaccines/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    vaccine = Vaccine.find_by(id: params[:id])

    if vaccine.nil?
      @message = SchemeMain::ERROR_MESSAGES_VACCINE[:vaccine_does_not_exist]
      return erb :'errors/404_admin' if @message
    else
      begin
        vaccine.delete
      rescue ActiveRecord::InvalidForeignKey => e
        flash[:danger] = SchemeMain::ERROR_MESSAGES_VACCINE[:can_not_be_deleted]
        redirect '/admin/vaccines'
      else
        flash[:success] = SchemeMain::ERROR_MESSAGES_VACCINE[:deleted_vaccine]
        redirect '/admin/vaccines'
      end
    end 
  end

  private

  def name
    @name ||= params[:name]
  end

  def series
    @series ||= params[:series]
  end

  def doses_number
    @doses_number ||= params[:doses_number]
  end

  def amount
    @amount ||= params[:amount]
  end

  def min_days_between_doses
    @min_days_between_doses ||= params[:min_days_between_doses]
  end

  def max_days_between_doses
    @max_days_between_doses ||= params[:max_days_between_doses]
  end

  def start_date
    @start_date ||= params[:start_date].to_datetime
  end

  def expiration_date
    @expiration_date ||= start_date + 30.days unless start_date.nil?
  end

  def vaccination_location_id
    @vaccination_location_id ||= params[:vaccination_location_id]
  end
end
