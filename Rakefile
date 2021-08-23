# frozen_string_literal: true'

# to load up enironment
require './config/environment'
# to get Rake tasks from the sinatra-activerecord gem
require 'sinatra/activerecord/rake'
Dir.glob('lib/tasks/*.rake').each { |r| load r}

namespace :db do
  desc 'migrate your database'
  task :migrate do
    require 'bundler'
    Bundler.require
    require './config/environment'
    ActiveRecord::MigrationContext.new('db/migrate', ActiveRecord::SchemaMigration).migrate
  end
end
