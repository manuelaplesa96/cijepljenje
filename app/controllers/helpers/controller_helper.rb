# frozen_string_literal: true

require 'pony'

module ControllerHelper
  def fetch_available_vaccination_time_slots(location_id)
    begin
      location = VaccinationLocation.find(location_id)
    rescue ActiveRecord::RecordNotFound => e
      message = e.message
    else
      location_and_time_slots = LocationAndTimeSlot.where(vaccination_location_id: location.id)
      available_location_and_time_slots = []
      location_and_time_slots.each do |el|
        available_location_and_time_slots << el unless Application.find_by(location_and_time_slot_id: el.id)
      end

      available_time_slots = []
      available_location_and_time_slots.each do |el|
        available_time_slots << VaccinationTimeSlot.find(el.vaccination_time_slot_id)
      end
    end
    available_time_slots || message
  end

  def fetch_applications_during_working_hours_of_vaccination_worker
    vaccination_worker = VaccinationWorker.find(session[:vaccination_worker_id])

    ApplicationRepository.applications_during_working_hours(vaccination_worker.id)
  end

  def role
    role = who_have_access + '_id' unless who_have_access.nil?

    role.to_sym
  end

  def who_have_access
    request.path_info.split('/')[1]
  end

  def redirecting_to_login?
    request.path_info == '/' + who_have_access + '/login'
  end

  def check_mbo(mbo)
    return SchemeMain::ERROR_MESSAGES_APPLICATION[:invalid_mbo] unless mbo.match(/^[0-9]{9}$/)
  end

  def check_oib(oib)
    return SchemeMain::ERROR_MESSAGES_APPLICATION[:invalid_oib] unless oib.match(/^[0-9]{11}$/)

    # checking control number: ISO7064, MOD 11,10 - Hibrid system
    control_sum = (0..9).inject(10) do |res, position|
      res += oib.at(position).to_i
      res %= 10
      res = 10 if res.zero?
      res *= 2
      res % 11
    end

    control_sum = 11 - control_sum
    control_sum = 0 if control_sum == 10

    SchemeMain::ERROR_MESSAGES_APPLICATION[:invalid_oib] unless control_sum == oib.at(10).to_i
  end

  def full_name(application)
    application.first_name + ' ' + application.last_name
  end

  def oib_or_mbo(application)
    return application.oib unless application.oib.nil?
    application.mbo
  end

  def send_email_with_application_id(email, message_body)
    Pony.options = {
      subject: "Cijepljenje",
      body: message_body,
      headers: { "Content-Type" => "text/html" },
      via: :smtp,
      via_options: {
        address: 'smtp.gmail.com',
        port: '587',
        enable_starttls_auto: true,
        user_name: SecretInfo::NO_REPLY[:email],
        password: SecretInfo::NO_REPLY[:password],
        authentication: :plain,
        domain: "localhost.cijepljenje"
      }
    }

    Pony.mail(from: SecretInfo::NO_REPLY[:email], :to => email)
  end

  def generating_qr_code(data)
    # generating qr code and passport
    qrcode = RQRCode::QRCode.new(data, size: 8, level: :m, mode: :string)

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )

    # generating png file
    File.open('public/images/potvrda.png', 'wb') do |f|
      f.write(Base64.decode64(Base64.strict_encode64(png.to_s)))
    end
  end

  def date_and_time_format(datetime)
    datetime.strftime('%d.%m.%Y., %H:%M')
  end

  def date_format(datetime)
    datetime.strftime('%d.%m.%Y.')
  end
end
