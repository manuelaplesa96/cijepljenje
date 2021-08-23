# frozen_string_literal: true

class SecretInfo
  def self.extract_fields(fields)
    HASH.map { |k, v| v if fields.include? k }.compact
  end

  NO_REPLY = {
    email: 'cijepljenje.noreply@gmail.com',
    password: 'PUNdHIblenDI',
  }.freeze

end
