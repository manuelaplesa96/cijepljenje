# frozen_string_literal: true

require 'rqrcode'

class PassportsController < AppController
  include ControllerHelper

  set :views, File.expand_path('../views', __dir__)
  set :static, true
  set :root, File.dirname(__FILE__)
  set :public_folder, 'public'

  get '/passport' do
    # fetch passport.png from lib/passports and show it in passport index page
    @title = 'Cijepljenje'
    erb :'passport/index'
  end

  get '/passport/show' do
    @title = 'Cijepljenje'
    erb :'passport/show'
  end

  post '/passport' do
    # fetch aplication
    if application.nil?
      flash[:warning] = SchemeMain::ERROR_MESSAGES_APPLICATION[:application_does_not_exist]
      redirect '/passport'
    end

    # check if status is finished
    if application.status != Application.statuses[:gotovo]
      flash[:warning] = SchemeMain::ERROR_MESSAGES_APPLICATION[:vaccination_is_not_finished]
      redirect '/passport'
    end

    # vaccination is finished and we must create passport
    # needed data: first name, last name, oib/mbo vaccine, date of last vaccination
    data = "Potvrda ##{application.reference}" + "\n\n" + 'Ime i prezime: ' + name + "\n" + 'OIB\MBO: ' + idetification_number.to_s + "\n" + 'Cjepivo: ' + vaccine.series + "\n"
    @reference = params[:application_reference]
    generating_qr_code(data)

    erb :'/passport/show'
  end

  private

  def delete_passport
    File.delete('lib/passports/potvrda.png')
  end

  def application
    @application ||= Application.find_by(reference: params[:application_reference])
  end

  def vaccination
    @vaccination ||= Vaccination.where(application_id: application.id).last
  end

  def vaccine
    @vaccine ||= vaccination.vaccine
  end

  def date_of_vaccination
    @date_of_vaccination ||= application.location_and_time_slot.vaccination_time_slot.date_and_time
  end

  def name
    @name ||= full_name(application)
  end

  def idetification_number
    @idetification_number ||= oib_or_mbo(application)
  end

  def email
   @email ||= application.email
  end
end
