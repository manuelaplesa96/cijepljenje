# frozen_string_literal: true

module CreateLocationAndTimeSlotsHelper
  def create_vaccination_time_slots(vaccine)
    start_date = vaccine.start_date.strftime('%Y-%m-%d').split('-')
    amount = vaccine.amount

    # needs to create vaccine amount number of time_slots from start_date 08:00
    # every 20min until 20:00 every day except between 13:00h and 14:00h
    # then is break

    # for how much days we need to create vaccination time slots
    # we can have 33 applications per day
    how_much_days = amount / 33

    # not full day -> number of application that we can have on that extra day
    how_much_on_extra_day = amount - (how_much_days * 33)

    start = DateTime.new(start_date[0].to_i, start_date[1].to_i, start_date[2].to_i, 8).utc
    stop = DateTime.new(start_date[0].to_i, start_date[1].to_i, start_date[2].to_i+how_much_days-1, 19, 40).utc

    # create list of time slots every 20 minutes -> full days
    date_and_times = list_of_date_and_times(how_much_days, start, stop)

    # add how much we need for extra day
    date_and_times = add_time_date_and_times_for_extra_days(stop, how_much_on_extra_day, date_and_times)

    date_and_times.each do |date_and_time|
      vaccination_time_slot = VaccinationTimeSlot.create(
        date_and_time: date_and_time
      )

      create_locations_and_time_slots(vaccination_time_slot, vaccine)
    end
  end

  def create_locations_and_time_slots(vaccination_time_slot, vaccine)
    location = VaccinationLocation.find_by(id: vaccine.vaccination_location_id)

    LocationAndTimeSlot.create(
      vaccination_time_slot: vaccination_time_slot,
      vaccine: vaccine,
      vaccination_location: location
    )
  end

  def get_vaccines_without_time_slots
    vaccines = Vaccine.all
    vaccines_without_time_slots = []
    vaccines.each do |vaccine|
      location_and_time_slot = LocationAndTimeSlot.find_by(vaccine_id: vaccine.id)
      vaccines_without_time_slots << vaccine if location_and_time_slot.nil?
    end
    vaccines_without_time_slots
  end

  def add_time_date_and_times_for_extra_days(stop, how_much_on_extra_day, date_and_times)
    stop = (stop + 1.day).strftime('%Y-%m-%d').split('-')
    minutes = 0
    hour = 8
    until how_much_on_extra_day.zero?
      if minutes >= 60
        minutes = 0
        hour += 1
      end

      new_date_and_time = DateTime.new(stop[0].to_i, stop[1].to_i, stop[2].to_i, hour, minutes).utc
      new_date_and_time_checker = new_date_and_time.strftime('%m/%d/%Y %H:%M').split[1].split[0].to_i

      date_and_times << new_date_and_time if new_date_and_time_checker.between?(8, 19) && new_date_and_time_checker != 13
      minutes += 20 if (minutes / 60).zero?

      how_much_on_extra_day -= 1
    end
    date_and_times
  end

  def list_of_date_and_times(how_much_days, start, stop)
    date_and_times = []
    unless how_much_days.zero?
      (start.to_i..stop.to_i).step(1200).each do |element|
        time_slot = Time.at(element).to_datetime.utc

        time_slot_checker = time_slot.strftime('%m/%d/%Y %H:%M').split[1].split[0].to_i

        date_and_times << Time.at(element).to_datetime.utc if time_slot_checker.between?(8, 19) && time_slot_checker != 13
      end
    end

    date_and_times
  end
end
