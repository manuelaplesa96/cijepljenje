# frozen_string_literal: true

module ChangeApplicationsStatuses
  def change_statuses(applications)
    applications.each do |application|
      status = application.status
      next unless ['doza_1', 'doza_2', 'doza_3'].include?(status)
      
      vaccine_doses_number = Vaccination.find_by(application_id: application.id).vaccine.doses_number
      dose_number = status.split('_')[1].to_i

      if dose_number == vaccine_doses_number
        application.finished
      else
        application.needs_to_continue_vaccination
      end
      application.save
    end
  end
end
