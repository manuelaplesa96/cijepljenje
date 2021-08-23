# frozen_string_literal: true

class VaccinationLocationsController < AppController
  include ControllerHelper

  set :views, File.expand_path('../views', __dir__)

  get '/admin/vaccination_locations' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @vaccination_locations = VaccinationLocation.all

    erb :'/vaccination_location/index'
  end

  get '/admin/vaccination_locations/new' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @counties = all_counties()

    erb :'/vaccination_location/new'
  end

  get '/admin/vaccination_locations/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @vaccination_location = VaccinationLocation.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_VACCINATION_LOCATION[:vaccination_location_does_not_exist] if @vaccination_location.nil?
    
    if @message
      erb :'errors/404_admin'
    else
      erb :'vaccination_location/show'
    end
  end

  post '/admin/vaccination_locations' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    begin
      vaccination_location = VaccinationLocation.create!(
        address: address,
        city: city,
        county: county,
        admin_id: session[:admin_id]
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/admin/vaccination_locations/new'
    else
      vaccination_location.to_json
      redirect '/admin/vaccination_locations'
    end
  end

  delete '/admin/vaccination_locations/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    vaccination_location = VaccinationLocation.find_by(id: params[:id])
    if vaccination_location.nil?
      @message = SchemeMain::ERROR_MESSAGES_VACCINATION_LOCATION[:vaccination_location_does_not_exist]
      return erb :'errors/404_admin'
    else
      begin
        vaccination_location.delete
      rescue ActiveRecord::InvalidForeignKey => e
        flash[:danger] = SchemeMain::ERROR_MESSAGES_VACCINATION_LOCATION[:can_not_be_deleted]
        redirect '/admin/vaccination_locations'
      else
        flash[:success] = SchemeMain::ERROR_MESSAGES_VACCINATION_LOCATION[:deleted_vaccintion_location]
        redirect '/admin/vaccination_locations'
      end
    end  
  end

  private

  def address
    @address ||= params[:address]
  end

  def city
    @city ||= params[:city]
  end

  def county
    @county ||= params[:county]
  end

  def all_counties
    [
      'Zagrebačka',
      'Krapinsko-zagorska',
      'Sisačko-moslavačka',
      'Karlovačka',
      'Varaždinska',
      'Korpivničko-križevačka',
      'Bjelovarko-bilogorska',
      'Primorsko-goranska',
      'Ličko-senjska',
      'Požeško-slavonska',
      'Brodsko-posavska',
      'Zadarska',
      'Osječko-baranjska',
      'Šibensko-kninska',
      'Vukovarsko-srijemska',
      'Splitsko-dalkatinska',
      'Istarska',
      'Dubrovačko-neretvanska',
      'Medimurska',
      'Grad Zagreb'
    ]
  end
end
