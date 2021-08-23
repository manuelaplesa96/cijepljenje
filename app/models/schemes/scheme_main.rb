# frozen_string_literal: true

class SchemeMain
  def self.extract_fields(fields)
    HASH.map { |k, v| v if fields.include? k }.compact
  end

  ERROR_MESSAGES_APPLICATION = {
    application_does_not_exist: "Prijava ne postoji!",
    invalid_status: 'Wrong value for status',
    invalid_mbo: 'Vrijednost MBO nije valjana!',
    invalid_oib: 'Vrijednost OIB nije valjana!',
    application_is_not_during_working_hours: "Application isn't during working hours",
    vaccination_is_not_finished: 'Proces cijepljenja nije završen!',
    oib_already_taken: 'Validation failed: Oib has already been taken',
    mbo_already_taken: 'Validation failed: Mbo has already been taken',
    empty_first_name: "Validation failed: First name can't be blank",
    empty_last_name: "Validation failed: Last name can't be blank",
    empty_birth: "Validation failed: Birth date can't be blank",
    empty_gender: "Validation failed: Gender can't be blank",
    empty_email: "Validation failed: Email can't be blank, Email is invalid",
    empty_location: "Validation failed: Vaccination location can't be blank",
    empty_author: "Validation failed: Author can't be blank"
  }.freeze

  ERROR_MESSAGES_DOCTOR = {
    doctor_does_not_exist: "Liječnik ne postoji!",
    email_already_exist: 'Email već postoji!',
    deleted_doctor: 'Liječnik je obrisan!',
  }.freeze

  ERROR_MESSAGES_SUPER_USER = {
    super_user_does_not_exist: "Predstavnik prioriteta ne postoji!",
    email_already_exist: 'Email već postoji!',
    deleted_super_user: 'Predstavnik prioriteta je obrisan!',
  }.freeze

  ERROR_MESSAGES_VACCINATION_WORKER = {
    vaccination_worker_does_not_exist: "Cjepitelj ne postoji!",
    email_already_exist: 'Email već postoji!',
    deleted_vaccination_worker: 'Cjepitelj je obrisan!',
  }.freeze

  ERROR_MESSAGES_VACCINATION_LOCATION = {
    vaccination_location_does_not_exist: "Mjesto cijepljenja ne postoji!",
    deleted_vaccintion_location: 'Mjesto cijepljenja je obrisano!',
    can_not_be_deleted: 'Mjesto cijepljenja se ne može obrisati!'
  }.freeze

  ERROR_MESSAGES_VACCINATION = {
    vaccination_does_not_exist: "Cijepljenje ne postoji!",
    wrong_vaccine_dose: 'Kriva vrijednost za dozu cjepiva!'
  }.freeze

  ERROR_MESSAGES_VACCINE = {
    vaccine_does_not_exist: "Cjepivo ne postoji!",
    deleted_vaccine: 'Cjepivo je obrisano!',
    can_not_be_deleted: 'Cjepivo ne može biti obrisano!'
  }.freeze

  ALERT_MESSAGE = {
    successfull: 'Zahtjev je uspješno zaprimljen.',
    successfull_vaccination: 'Cijepljenje je uspješno spremljeno!',
    unsuccessfull: 'Nisu popunjena sva potrebna polja.',
    error_during_login: 'Krivi podaci!',
    pending_resolve: 'Prijava prihvaćena'
  }.freeze
end
