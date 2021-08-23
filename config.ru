# frozen_string_literal: true

require './config/environment'

# if ActiveRecord::Migrator.needs_migration?
#   raise 'Migrations are pending. Run `rake db:migrate` to resolve the issue.'
# end

use AppController
use AdminsController
use AdminsSecurityController
use DoctorsController
use DoctorsSecurityController
use SuperUsersController
use SuperUsersSecurityController
use VaccinationWorkersController
use VaccinationWorkersSecurityController
use ApplicationsController
use VaccinationLocationsController
use VaccinationTimeSlotsController
use VaccinesController
use VaccinationsController
use PassportsController

run AppController
