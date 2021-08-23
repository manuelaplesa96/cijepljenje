# frozen_string_literal: true

class ApplicationRepository
  def self.applications_during_working_hours(vaccination_worker_id)
    sql = "SELECT applications.id, first_name, last_name, birth_date, gender, applications.email, chronic_patient, status, "\
    "applications.vaccination_location_id, location_and_time_slot_id, author_type, author_id,"\
    "mbo, oib, phone_number, sector, reference, applications.updated_at, applications.created_at "\
    "FROM applications "\
    "JOIN vaccination_locations ON applications.vaccination_location_id = vaccination_locations.id "\
    "LEFT JOIN vaccination_workers ON vaccination_locations.id = vaccination_workers.vaccination_location_id "\
    "JOIN location_and_time_slots ON applications.location_and_time_slot_id = location_and_time_slots.id "\
    "LEFT JOIN vaccination_time_slots ON location_and_time_slots.vaccination_time_slot_id = vaccination_time_slots.id "\
    "WHERE vaccination_workers.id = #{vaccination_worker_id} AND vaccination_time_slots.date_and_time "\
    "BETWEEN (SELECT TO_TIMESTAMP(CONCAT(CURRENT_DATE, ' ', start_work_time), 'YYYY-MM-DD HH24:MI') FROM vaccination_workers "\
    "WHERE id = #{vaccination_worker_id}) AND (SELECT TO_TIMESTAMP(CONCAT(CURRENT_DATE, ' ', end_work_time), 'YYYY-MM-DD HH24:MI')"\
    "FROM vaccination_workers WHERE id = #{vaccination_worker_id}) AND status = '#{Application.statuses['rezervirano']}';"

    Application.connection.select_all(sql).to_a
  end
end
