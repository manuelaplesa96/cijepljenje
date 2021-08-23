# frozen_string_literal: true

class SuperUsersController < AppController
  include ControllerHelper
  
  set :views, File.expand_path('../../views', __dir__)

  get '/super_user' do
    redirect_if_not_logged_in?(:super_user_id)

    @title = 'Cijepljenje'
    redirect 'super_user/applications/new'
  end

  get '/admin/super_users' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @super_users = SuperUser.all

    erb :'/super_user/index'
  end

  get '/admin/super_users/new' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    
    erb :'/super_user/new'
  end

  get '/admin/super_users/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @super_user = SuperUser.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_SUPER_USER[:super_user_does_not_exist] unless @super_user
    
    if @message
      erb :'errors/404_admin'
    else
      erb :'super_user/show'
    end
  end

  put '/admin/super_users/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    @message = nil
    super_user = SuperUser.find_by(id: params[:id])
    @message = SchemeMain::ERROR_MESSAGES_SUPER_USER[:super_user_does_not_exist] unless super_user
    return erb :'errors/404_admin' if @message

    super_user.sector = params[:sector]

    if super_user.email != email
      @message = email_already_exist
      super_user.email = email unless @message
    end

    super_user.save
    redirect '/admin/super_users'
  end

  post '/admin/super_users' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    begin
      super_user = SuperUser.create!(
        email: email,
        password: password,
        sector: sector,
        admin_id: session[:admin_id]
      )
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = SchemeMain::ALERT_MESSAGE[:unsuccessfull]
      redirect '/admin/super_users/new'
    else
      super_user.to_json
      redirect '/admin/super_users'
    end
  end

  delete '/admin/super_users/:id' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    super_user = SuperUser.find_by(id: params[:id])
    if super_user.nil? 
      @message = SchemeMain::ERROR_MESSAGES_SUPER_USER[:super_user_does_not_exist]
      return erb :'errors/404_admin'
    else
      begin
        super_user.delete
      rescue ActiveRecord::InvalidForeignKey => e
        flash[:danger] = SchemeMain::ERROR_MESSAGES_SUPER_USER[:can_not_be_deleted]
        redirect '/admin/super_users'
      else
        flash[:success] = SchemeMain::ERROR_MESSAGES_SUPER_USER[:deleted_super_user]
        redirect '/admin/super_users'
      end
    end
  end

  private

  def email
    @email ||= params[:email]
  end

  def password
    @password ||= params[:password]
  end

  def sector
    @sector ||= params[:sector]
  end

  def email_already_exist
    super_user = SuperUser.find_by(email: email)
    return SchemeMain::ERROR_MESSAGES_SUPER_USER[:email_already_exist] if super_user
  end
end
