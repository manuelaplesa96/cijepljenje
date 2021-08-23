# frozen_string_literal: true

class SuperUsersSecurityController < AppController
  set :views, File.expand_path('../../views', __dir__)

  get '/super_user/login' do
    @title = 'Cijepljenje'
    erb :'super_user/login'
  end

  post '/super_user/login' do
    begin
      super_user = SuperUser.find_by(email: params[:email])
    rescue ActiveRecord::RecordNotFound => e
      e.message
    else
      if super_user&.authenticate(params[:password]) && !logged_in_super_user?
        session['super_user_id'] = super_user.id

        redirect '/super_user'
      else
        @error = true
        flash[:warning] = SchemeMain::ALERT_MESSAGE[:error_during_login]
        redirect '/super_user/login'
      end
    end
  end

  get '/super_user/logout' do
    session[:super_user_id] = nil
    redirect '/super_user/login'
  end
end
