# frozen_string_literal: true

class AdminsSecurityController < AppController
  set :views, File.expand_path('../../views', __dir__)

  get '/admin/login' do
    @title = 'Cijepljenje'
    erb :'admin/login'
  end

  post '/admin/login' do
    begin
      admin = Admin.find_by(email: params[:email])
    rescue ActiveRecord::RecordNotFound => e
      e.message
    else
      if admin&.authenticate(params[:password]) && !logged_in_admin?
        session[:admin_id] = admin.id
        redirect '/admin'
      else
        @error = true
        flash[:warning] = SchemeMain::ALERT_MESSAGE[:error_during_login]
        redirect '/admin/login'
      end
    end
  end

  get '/admin/logout' do
    session[:admin_id] = nil
    redirect '/admin/login'
  end
end
