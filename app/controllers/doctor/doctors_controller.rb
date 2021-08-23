# frozen_string_literal: true

class DoctorsController < AppController
  include ControllerHelper

  set :views, File.expand_path('../../views', __dir__)

  get '/doctor' do
    redirect_if_not_logged_in?(:doctor_id)

    @title = 'Cijepljenje'
    
    redirect '/doctor/applications'
  end

  get '/admin/doctors' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @doctors = Doctor.all
    
    erb :'/doctor/index'
  end

  get '/admin/doctors/new' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    
    erb :'/doctor/new'
  end

  get '/admin/doctors/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @doctor = Doctor.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_DOCTOR[:doctor_does_not_exist] unless @doctor
    
    if @message
      erb :'errors/404_admin'
    else
      erb :'doctor/show'
    end
  end

  put '/admin/doctors/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @message = nil
    doctor = Doctor.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_DOCTOR[:doctor_does_not_exist] if doctor.nil?
    return erb :'errors/404_admin' if @message

    doctor.first_name = params[:first_name]
    doctor.last_name = params[:last_name]

    if doctor.email != email
      @message = email_already_exist
      doctor.email = email unless @message
    end

    doctor.save
    redirect '/admin/doctors'
  end

  post '/admin/doctors' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    begin
      doctor = Doctor.create!(
        email: email,
        first_name: first_name,
        last_name: last_name,
        password: password,
        admin_id: session[:admin_id]
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/admin/doctors/new'
    else
      redirect '/admin/doctors'
    end
  end

  delete '/admin/doctors/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    doctor = Doctor.find_by(id: params[:id])
    if doctor.nil?
      @message = SchemeMain::ERROR_MESSAGES_DOCTOR[:doctor_does_not_exist] 
      return erb :'errors/404_admin'
    else
      begin
        doctor.delete
      rescue ActiveRecord::InvalidForeignKey => e
        flash[:danger] = SchemeMain::ERROR_MESSAGES_DOCTOR[:can_not_be_deleted]
        redirect '/admin/doctors'
      else
        flash[:success] = SchemeMain::ERROR_MESSAGES_DOCTOR[:deleted_doctor]
        redirect '/admin/doctors'
      end
    end
    redirect '/admin/doctors'
  end

  private

  def email
    @email ||= params[:email]
  end

  def password
    @password ||= params[:password]
  end

  def first_name
    @first_name ||= params[:first_name]
  end

  def last_name
    @last_name ||= params[:last_name]
  end

  def email_already_exist
    doctor = Doctor.find_by(email: email)
    return SchemeMain::ERROR_MESSAGES_DOCTOR[:email_already_exist] if doctor
  end
end
