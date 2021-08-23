# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
#
# Examples:
#
#  movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#  Character.create(name: 'Luke', movie: movies.first)

admin = Admin.create!(
  email: 'admin@example.com',
  password: 'asdfasdf'
)

doctor = Doctor.create!(
  email: 'doctor1@example.com',
  password: 'asdfasdf',
  admin: admin,
  first_name: 'Test',
  last_name: 'Doctor'
)

super_user = SuperUser.create!(
  email: 'superuser1@example.com',
  password: 'asdfasdf',
  admin: admin,
  sector: 'Medical Institution'
)

vaccination_location = VaccinationLocation.create!(
  address: 'Relkovićeva 11',
  city: 'Nova Gradiška',
  county: 'Brodsko-posavska',
  admin: admin
)

vaccination_worker = VaccinationWorker.create!(
  email: 'vaccination.worker1@example.com',
  password: 'asdfasdf',
  start_work_time: '08:00',
  end_work_time: '13:00',
  time_zone: 'Europe/Sarajevo',
  vaccination_location_id: vaccination_location.id,
  admin: admin
)

vaccine = Vaccine.create!(
  name: 'Phizer',
  series: 'ABC-123',
  doses_number: 3,
  amount: 6,
  min_days_between_doses: 15,
  max_days_between_doses: 24,
  start_date: DateTime.new(2021, 1, 1, 10),
  expiration_date: DateTime.new(2022, 1, 1, 10) + 42.days,
  admin: admin,
  vaccination_location_id: vaccination_location.id
)

Vaccine.create!(
  name: 'Phizer',
  series: 'ABC-456',
  doses_number: 2,
  amount: 120,
  min_days_between_doses: 15,
  max_days_between_doses: 24,
  start_date: DateTime.new(2021, 1, 10, 10),
  expiration_date: DateTime.new(2022, 1, 10, 10) + 40.days,
  admin: admin,
  vaccination_location_id: vaccination_location.id
)

Vaccine.create!(
  name: 'Moderna',
  series: 'MNO-234',
  doses_number: 2,
  amount: 90,
  min_days_between_doses: 15,
  max_days_between_doses: 20,
  start_date: DateTime.new(2021, 1, 15, 10),
  expiration_date: DateTime.new(2022, 1, 15, 10) + 50.days,
  admin: admin,
  vaccination_location_id: vaccination_location.id
)

Vaccine.create!(
  name: 'Moderna',
  series: 'MNO-567',
  doses_number: 2,
  amount: 90,
  min_days_between_doses: 15,
  max_days_between_doses: 20,
  start_date: DateTime.new(2021, 8, 3, 10),
  expiration_date: DateTime.new(2022, 8, 1, 10) + 50.days,
  admin: admin,
  vaccination_location_id: vaccination_location.id
)

vaccination_time_slot = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 1, 10)
)

vaccination_time_slot2 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 1, 10) + 2.days
)

vaccination_time_slot3 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 1, 10) + 7.days
)

vaccination_time_slot4 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 1, 9) + 7.days
)

vaccination_time_slot5 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 1, 8) + 8.days
)

vaccination_time_slot6 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 8, 8, 20)
)

next_dose = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 9, 8, 20) + 20.days
)

vaccination_time_slot7 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 10, 8, 20)
)

vaccination_time_slot8 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 11, 8, 20)
)

vaccination_time_slot9 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 1, 8, 8, 20)
)

for_finished = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 11, 18, 8, 20)
)

for_during_working_hours = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 8, 11, 9, 20)
)

for_during_working_hours2 = VaccinationTimeSlot.create!(
  date_and_time: DateTime.new(2021, 8, 11, 10, 40)
)

location_and_time_slot = LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: vaccination_time_slot,
  vaccine: vaccine
)

LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: vaccination_time_slot3,
  vaccine: vaccine
)

LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: vaccination_time_slot4,
  vaccine: vaccine
)

location_and_time_slot5 = LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: vaccination_time_slot5,
  vaccine: vaccine
)

location_and_time_slot6 = LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: vaccination_time_slot6,
  vaccine: vaccine
)

LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: next_dose,
  vaccine: vaccine
)

finished_location_and_time_slot = LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: for_finished,
  vaccine: vaccine
)

during_working_hours = LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: for_during_working_hours,
  vaccine: vaccine
)

during_working_hours2 = LocationAndTimeSlot.create!(
  vaccination_location: vaccination_location,
  vaccination_time_slot: for_during_working_hours2,
  vaccine: vaccine
)

# application during working hours - needs to change date every day if wants to work
Application.create!(
  first_name: 'Test',
  last_name: 'Patient',
  birth_date: Date.new(1996, 12, 10),
  gender: 'F',
  mbo: 222_222_222,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:rezervirano],
  chronic_patient: false,
  vaccination_location: vaccination_location,
  location_and_time_slot: during_working_hours,
  reference: 'Test' + '-' + 'Patient' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# application during working hours - needs to change date every day if wants to work
during_working_hours_with_one_dose = Application.create!(
  first_name: 'Test',
  last_name: 'Patient',
  birth_date: Date.new(1996, 12, 10),
  gender: 'F',
  mbo: 333_333_333,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:rezervirano],
  chronic_patient: false,
  vaccination_location: vaccination_location,
  location_and_time_slot: during_working_hours2,
  reference: 'Test' + '-' + 'Patient' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# with status 'u obradi' with false for chronic patient
application = Application.create!(
  first_name: 'Test',
  last_name: 'Patient',
  birth_date: Date.new(1996, 12, 10),
  gender: 'F',
  oib: 216_640_234_32,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:ceka_termin],
  chronic_patient: false,
  vaccination_location: vaccination_location,
  author: doctor,
  reference: 'Test' + '-' + 'Patient' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# with status 'u obradi' with true for chronic patient
Application.create!(
  first_name: 'Test',
  last_name: 'Patient2',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  oib: 688_462_787_14,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:u_obradi],
  chronic_patient: true,
  vaccination_location: vaccination_location,
  author: doctor,
  reference: 'Test' + '-' + 'Patient2' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"

)

# with status 'ceka termin' with false for chronic patient
regular_patient = Application.create!(
  first_name: 'Test',
  last_name: 'Patient3',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 135_357_579,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:ceka_termin],
  chronic_patient: false,
  vaccination_location: vaccination_location,
  author: doctor,
  reference: 'Test' + '-' + 'Patient3' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"

)

# with status 'ceka termin' with true for chronic patient
chronic_patient = Application.create!(
  first_name: 'Test',
  last_name: 'Patient4',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 135_753_579,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:ceka_termin],
  chronic_patient: true,
  vaccination_location: vaccination_location,
  author: doctor,
  reference: 'Test' + '-' + 'Patient4' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# with status 'ceka termin' and sector 
application_with_sector = Application.create!(
  first_name: 'Test',
  last_name: 'Patient5',
  birth_date: Date.new(1996, 12, 10),
  gender: 'F',
  mbo: 123_456_789,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:ceka_termin],
  chronic_patient: false,
  sector: super_user.sector,
  vaccination_location: vaccination_location,
  author: super_user,
  reference: 'Test' + '-' + 'Patient5' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"

)

# application with status 'ceka termin' but with 2 doses
application_with_dose = Application.create!(
  first_name: 'Test',
  last_name: 'Patient6',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 654_987_123,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  chronic_patient: true,
  status: Application.statuses[:doza_2],
  vaccination_location: vaccination_location,
  location_and_time_slot: location_and_time_slot6,
  author: doctor,
  reference: 'Test' + '-' + 'Patient6' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# with status 'odgodio' that can get new time slot
postponed_application = Application.create!(
  first_name: 'Test',
  last_name: 'Patient7',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 987_654_321,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  chronic_patient: true,
  status: Application.statuses[:odgodio],
  vaccination_location: vaccination_location,
  location_and_time_slot: location_and_time_slot,
  author: doctor,
  reference: 'Test' + '-' + 'Patient7' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# with status 'odgodio' that can not get new time slot
# unless we create new time slot with rake task
postpone_application2 = Application.create!(
  first_name: 'Test',
  last_name: 'Postpone',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 789_456_321,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  chronic_patient: true,
  status: Application.statuses[:odgodio],
  vaccination_location: vaccination_location,
  location_and_time_slot: location_and_time_slot5,
  author: doctor,
  reference: 'Test' + '-' + 'Postpone' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"

)

finished_vaccination = Application.create!(
  first_name: 'Test',
  last_name: 'Finished',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 654_987_222,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:doza_3],
  chronic_patient: true,
  vaccination_location: vaccination_location,
  location_and_time_slot: location_and_time_slot6,
  author: doctor,
  reference: 'Test' + '-' + 'Finished' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"

)

# not valid but application with finished vaccination
finished = Application.create!(
  first_name: 'Test',
  last_name: 'Finished',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 135_357_999,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:gotovo],
  chronic_patient: false,
  location_and_time_slot: finished_location_and_time_slot,
  vaccination_location: vaccination_location,
  author: doctor,
  reference: 'Test' + '-' + 'Finished' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# not valid but application with finished vaccination
finished2 = Application.create!(
  first_name: 'Test',
  last_name: 'Finished2',
  birth_date: Date.new(1996, 12, 10),
  gender: 'M',
  mbo: 133_357_999,
  email: 'test.patient@example.com',
  phone_number: 191_123_123_4,
  status: Application.statuses[:gotovo],
  chronic_patient: false,
  location_and_time_slot: finished_location_and_time_slot,
  vaccination_location: vaccination_location,
  author: doctor,
  reference: 'Test' + '-' + 'Finished2' + '-' + "#{SecureRandom.alphanumeric(8).upcase}"
)

# vaccination for application during working hours
Vaccination.create!(
  application: during_working_hours_with_one_dose,
  vaccine: vaccine,
  vaccination_time_slot: for_during_working_hours2,
  vaccination_worker: vaccination_worker,
  dose_number: 1
)

# vaccination for invalid finished application
Vaccination.create!(
  application: finished,
  vaccine: vaccine,
  vaccination_time_slot: vaccination_time_slot,
  vaccination_worker: vaccination_worker,
  dose_number: 3
)

# vaccination for invalid finished application
Vaccination.create!(
  application: finished2,
  vaccine: vaccine,
  vaccination_time_slot: vaccination_time_slot,
  vaccination_worker: vaccination_worker,
  dose_number: 3
)

Vaccination.create!(
  application: application_with_dose,
  vaccine: vaccine,
  vaccination_time_slot: vaccination_time_slot,
  vaccination_worker: vaccination_worker,
  dose_number: 1
)

Vaccination.create!(
  application: application_with_dose,
  vaccine: vaccine,
  vaccination_time_slot: vaccination_time_slot2,
  vaccination_worker: vaccination_worker,
  dose_number: 2
)

Vaccination.create!(
  application: finished_vaccination,
  vaccine: vaccine,
  vaccination_time_slot: vaccination_time_slot7,
  vaccination_worker: vaccination_worker,
  dose_number: 1
)

Vaccination.create!(
  application: finished_vaccination,
  vaccine: vaccine,
  vaccination_time_slot: vaccination_time_slot8,
  vaccination_worker: vaccination_worker,
  dose_number: 2
)

Vaccination.create!(
  application: finished_vaccination,
  vaccine: vaccine,
  vaccination_time_slot: vaccination_time_slot9,
  vaccination_worker: vaccination_worker,
  dose_number: 3
)
