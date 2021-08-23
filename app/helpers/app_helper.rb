# frozen_string_literal: true

require 'pony'

module AppHelper
  def parse_json(response)
    JSON.parse(response)
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

  def date_and_time_format(datetime)
    datetime.strftime('%d.%m.%Y., %H:%M')
  end

  def date_format(datetime)
    datetime.strftime('%d.%m.%Y.')
  end
end
