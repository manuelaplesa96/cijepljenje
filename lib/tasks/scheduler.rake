# frozen_string_literal: true

include CreateLocationAndTimeSlotsHelper
include AssignVaccinationTimeSlotToApplicationHelper
include ChangeApplicationsStatuses
include FetchingApplicationsHelper

namespace :scheduler do
  desc 'Creates vaccination time slots depending on vaccine and location of that vaccine'
  task :create_location_and_time_slots do
    vaccines_without_time_slots = get_vaccines_without_time_slots()

    vaccines_without_time_slots.each do |vaccine|
      create_vaccination_time_slots(vaccine)
    end
  end

  desc "Change statuses of application to 'ceka termin' or 'gotovo' depending on previous status"
  task :change_statuses_to_ceka_termin_or_gotovo do
    applications = Application.all
    change_statuses(applications) unless applications.empty?
  end

  desc 'Assign vaccination time slot to applications that waits for one'
  task :assign_vaccination_time_slot_to_application do
    # 1. get all applications with status 'odgodio'
    applications_with_status_postpone = get_applications_with_status_postpone()
    assign_vaccination_time_slot_for_postpone(applications_with_status_postpone) unless applications_with_status_postpone.empty?

    # 2. get all applications with status 'ceka termin' & with at least one dose until now
    applications_that_needs_another_dose = get_applications_that_needs_another_dose()
    assign_vaccination_time_slot_for_another_dose(applications_that_needs_another_dose) unless applications_that_needs_another_dose.include?(nil)

    # 3. get all application with status 'ceka termin' & with zero doses until now
    # assign time slot based on priorities
    applications_with_status_wait_time_slot = get_applications_with_status_wait_time_slot()
    assign_vaccination_time_slot_by_priorities(applications_with_status_wait_time_slot) unless applications_with_status_wait_time_slot.empty?
  end
end
