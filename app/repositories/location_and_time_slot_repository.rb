# frozen_string_literal: true

class LocationAndTimeSlotRepository
  def self.available_time_slot_without_vaccine(location, new_date_and_time_start_day, new_date_and_time_end_day)
    LocationAndTimeSlot.where(vaccination_location_id: location.id)
                       .left_outer_joins(:vaccination_time_slot)
                       .where('vaccination_time_slots.date_and_time BETWEEN ? AND ?', new_date_and_time_start_day, new_date_and_time_end_day)
                       .joins('LEFT JOIN applications ON applications.location_and_time_slot_id = vaccination_time_slots.id')
  end

  def self.available_time_slot_depending_on_vaccine(vaccine, location, new_date_and_time_start_day, new_date_and_time_end_day)
    LocationAndTimeSlot.where(vaccination_location_id: location.id)
                       .where(vaccine_id: vaccine.id)
                       .left_outer_joins(:vaccination_time_slot)
                       .where('vaccination_time_slots.date_and_time BETWEEN ? AND ?', new_date_and_time_start_day, new_date_and_time_end_day)
                       .joins('LEFT JOIN applications ON applications.location_and_time_slot_id = vaccination_time_slots.id')
  end

  # if we need to select location and time slot for application that already have beloging vaccine
  def self.available_time_slot(vaccine, location, new_date_and_time_start_day, new_date_and_time_end_day)
    if vaccine.nil?
      query = available_time_slot_without_vaccine(location, new_date_and_time_start_day, new_date_and_time_end_day)
    else
      query = available_time_slot_depending_on_vaccine(vaccine, location, new_date_and_time_start_day, new_date_and_time_end_day)
    end
    query
  end

  def self.available_time_slot_in_next_five_days(vaccine = nil, location, new_date_and_time_start_day, new_date_and_time_end_day)
    query = available_time_slot(vaccine, location, new_date_and_time_start_day, new_date_and_time_end_day)

    4.times do
      new_date_and_time_start_day += 1.day
      new_date_and_time_end_day += 1.day
      query = query.or(available_time_slot(vaccine, location, new_date_and_time_start_day, new_date_and_time_end_day))
    end
    query = query.order('vaccination_time_slots.date_and_time').limit(1)
    query
  end

  def self.available_time_slot_in_next_available_days(available_days, vaccine = nil, location, new_date_and_time_start_day, new_date_and_time_end_day)
    query = available_time_slot(vaccine, location, new_date_and_time_start_day, new_date_and_time_end_day)

    until available_days.zero?
      new_date_and_time_start_day += 1.day
      new_date_and_time_end_day += 1.day
      query = query.or(available_time_slot(vaccine, location, new_date_and_time_start_day, new_date_and_time_end_day))
      available_days -= 1
    end
    query = query.order('vaccination_time_slots.date_and_time').limit(1)
    query
  end
end
