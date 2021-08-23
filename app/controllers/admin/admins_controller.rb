# frozen_string_literal: true

class AdminsController < AppController
  include ControllerHelper

  set :views, File.expand_path('../../views', __dir__)

  get '/admin' do
    redirect_if_not_logged_in?(:admin_id)

    @title = 'Cijepljenje - Admin'
    redirect '/admin/doctors'
  end
end
