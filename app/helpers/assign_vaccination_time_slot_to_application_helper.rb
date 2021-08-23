# frozen_string_literal: true

include AppHelper

module AssignVaccinationTimeSlotToApplicationHelper
  def assign_vaccination_time_slot_for_postpone(applications)
    # we need to assign time slot at least one week from assigned time slot
    applications.each do |application|
      # change status from 'odgodio' to 'ceka termin'
      application.needs_to_continue_vaccination
      location = application.vaccination_location
      vaccination = Vaccination.find_by(application_id: application.id)
      vaccine = vaccination.vaccine unless vaccination.nil?  

      # we find what is old time slot
      old_time_slot = VaccinationTimeSlot.find_by(id: application.location_and_time_slot.vaccination_time_slot_id)

      location_and_time_slot_to_assign = find_available_time_slot(vaccine, location, old_time_slot).first

      if !location_and_time_slot_to_assign.nil?
        assign(application, location_and_time_slot_to_assign)
      else
        # this will be done if selected time is not available and we want to check next 5 days
        location_and_time_slot_to_assign = LocationAndTimeSlotRepository.available_time_slot_in_next_five_days(vaccine, location, old_time_slot.date_and_time.change(hour: 8), old_time_slot.date_and_time.change(hour: 19, min: 40))
        unless location_and_time_slot_to_assign.empty?
          assign(application, location_and_time_slot_to_assign.first)
        end
      end
    end
  end

  def assign_vaccination_time_slot_for_another_dose(applications)
    applications.each do |application|
      location = application.vaccination_location
      vaccine = Vaccination.find_by(application_id: application.id).vaccine
      min_days_between_doses = vaccine.min_days_between_doses

      available_days = vaccine.get_available_days
      old_time_slot = VaccinationTimeSlot.find_by(id: application.location_and_time_slot.vaccination_time_slot_id)

      # get day min days from doses
      until min_days_between_doses.zero?
        old_time_slot.date_and_time = old_time_slot.date_and_time + 1.days
        min_days_between_doses -= 1
      end
      location_and_time_slot_to_assign = find_available_time_slot(vaccine, location, old_time_slot).first

      if !location_and_time_slot_to_assign.nil?
        assign(application, location_and_time_slot_to_assign)
      else
        # this will be done if selected time is not available and we want to check next available number of days
        location_and_time_slot_to_assign = LocationAndTimeSlotRepository.available_time_slot_in_next_available_days(available_days, vaccine, location, old_time_slot.date_and_time.change(hour: 8), old_time_slot.date_and_time.change(hour: 19, min: 40))
        unless location_and_time_slot_to_assign.empty?
          assign(application, location_and_time_slot_to_assign.first)
        end
      end
    end
  end

  def assign_vaccination_time_slot_by_priorities(applications)
    applications_with_sector = applications_with_sector(applications)
    applications_with_chronic_patients = appplications_with_chronic_patients(applications)

    ## 1. applications with sector
    assign_for_priorities(applications_with_sector)
    ## 2. application with chronic patient
    assign_for_priorities(applications_with_chronic_patients)
    ## 3. all other applications that have zero dose
    assign_for_priorities(applications - (applications_with_sector + applications_with_chronic_patients))
  end

  def assign_for_priorities(applications)
    applications.each do |application|
      location = application.vaccination_location
      # get date of creating application - date is today
      # check if a week from today exist available time slot and 5 days after that
      time_of_creating = VaccinationTimeSlot.create(date_and_time: application.created_at.change(hour: 8, min: 0) + 7.days)
      location_and_time_slot_to_assign = find_available_time_slot(nil, location, time_of_creating).first

      if !location_and_time_slot_to_assign.nil?
        assign(application, location_and_time_slot_to_assign)
      else
        # this will be done if selected time is not available and we want to check next day
        location_and_time_slot_to_assign = LocationAndTimeSlotRepository.available_time_slot_in_next_five_days(nil, location, time_of_creating.date_and_time.change(hour: 8), time_of_creating.date_and_time.change(hour: 19, min: 40))
        unless location_and_time_slot_to_assign.empty?
          assign(application, location_and_time_slot_to_assign.first)
        end
      end
    end
  end

  def find_available_time_slot(vaccine, location, old_time_slot)
    if vaccine.nil?
      LocationAndTimeSlotRepository.available_time_slot_without_vaccine(location, old_time_slot.date_and_time.change(hour: 8), old_time_slot.date_and_time.change(hour: 19, min: 40)) 
    else
      LocationAndTimeSlotRepository.available_time_slot_depending_on_vaccine(vaccine, location, old_time_slot.date_and_time.change(hour: 8), old_time_slot.date_and_time.change(hour: 19, min: 40)) 
    end
  end

  def assign(application, location_and_time_slot_to_assign)
    application.location_and_time_slot_id = location_and_time_slot_to_assign.id
    application.time_slot_assigned
    application.save
    time_and_date = date_and_time_format(location_and_time_slot_to_assign.vaccination_time_slot.date_and_time)
    address = application.vaccination_location.address
    city = application.vaccination_location.city
    message_body = "<h2>Termin cijepljenja za zahtjev ##{application.reference}</h2><p>Vrijem cijepljenja: #{time_and_date} <br>Adresa mjesta cijepljenja: #{address}, #{city}</p>"
    send_email_with_application_id(application.email, message_body)
  end
end
