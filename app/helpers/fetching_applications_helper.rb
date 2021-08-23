# frozen_string_literal: true

module FetchingApplicationsHelper
  def get_applications_with_status_postpone
    Application.where(status: Application.statuses[:odgodio])
  end

  def get_applications_that_needs_another_dose
    # need to fetch all application that have at least one dose of vaccine
    # fetch from vaccination table all applications only one time and return that applications
    applications = []
    ## TODO query
    Vaccination.all.each do |vaccination|
      applications << Application.find_by(id: vaccination.application_id, status: Application.statuses[:ceka_termin])
    end

    applications.uniq
  end

  def get_applications_with_status_wait_time_slot
    Application.where(status: Application.statuses[:ceka_termin], location_and_time_slot: nil)
  end

  def applications_with_sector(applications)
    applications_with_sector = []
    applications.each do |application|
      applications_with_sector << application unless application.sector.nil?
    end
    applications_with_sector
  end

  def appplications_with_chronic_patients(applications)
    chronic_patients = []
    applications.each do |application|
      chronic_patients << application if application.chronic_patient
    end
    chronic_patients
  end
end
