# frozen_string_literal: true

ENV['SINATRA_ENV'] ||= 'development'

require 'active_support/all'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/flash'
Bundler.require

configure :development do
  Bundler.require(:default)

  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    database: "db/#{ENV['SINATRA_ENV']}_cijepi-se"
  )
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')
 
  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
 end

require './app/controllers/app_controller'
require './app/controllers/helpers/controller_helper'
require_all 'app'
