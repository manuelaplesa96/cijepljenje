# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.2'

gem 'aasm', '~> 5.1', '>= 5.1.1'
gem 'activerecord', require: 'active_record'
gem 'activesupport'
gem 'bcrypt', '~> 3.1', '>= 3.1.12'
gem 'byebug'
gem 'chunky_png', '~> 1.3', '>= 1.3.5'
gem 'data_mapper'
gem 'dm-postgres-adapter', '~> 1.2'
gem 'json', '~> 1.8.6'
gem 'prawn'
gem 'pg'
gem 'pony', '~> 1.11'
gem 'require_all'
gem 'rqrcode', '~> 2.0'
gem 'prawn-qrcode'
gem 'sinatra-activerecord'
gem 'bootstrap'
gem 'sinatra-flash'

group :development, :test do
  gem 'factory_bot_rails', '>= 4.8.2'
end

group :development do
  gem 'rspec-rails'
  gem 'tux'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'rack-test'
  gem 'shoulda-matchers', '~> 4.0'
end

group :production, :development, :test do
  gem 'rake'
  gem 'thin'
end
