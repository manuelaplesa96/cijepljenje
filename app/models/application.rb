# frozen_string_literal: true

class Application < ActiveRecord::Base
  include AASM

  belongs_to :author, polymorphic: true
  belongs_to :vaccination_location
  belongs_to :location_and_time_slot
  has_many :vaccinations

  validates :reference, :first_name, :last_name, :birth_date, :gender, :email, :status, :vaccination_location, presence: true
  validates :mbo, presence: true, if: :oib_nil?
  validates :oib, presence: true, if: :mbo_nil?
  validates :oib, :mbo, uniqueness: true, allow_nil: true
  validates :reference, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  enum status: {
    :u_obradi => 'u obradi',
    :odustao => 'odustao',
    :odgodio => 'odgodio',
    :gotovo => 'gotovo',
    :ceka_termin => 'ceka termin',
    :doza_1 => '1.doza',
    :doza_2 => '2.doza',
    :doza_3 => '3.doza',
    :rezervirano => 'rezervirano'
  }

  aasm column: :status, enum: true do
    state :u_obradi, initial: true
    state :odustao
    state :odgodio
    state :gotovo
    state :ceka_termin
    state :doza_1
    state :doza_2
    state :doza_3
    state :rezervirano

    event :resolve_chronic_patient do
      transitions from: :u_obradi, to: :ceka_termin
    end

    event :time_slot_assigned do
      transitions from: :ceka_termin, to: :rezervirano
    end

    event :vaccination_with_dose_1 do
      transitions from: :rezervirano, to: :doza_1
    end

    event :vaccination_with_dose_2 do
      transitions from: :rezervirano, to: :doza_2
    end

    event :vaccination_with_dose_3 do
      transitions from: :rezervirano, to: :doza_3
    end

    event :needs_to_continue_vaccination do
      transitions from: [:doza_1, :doza_2, :doza_3, :odgodio], to: :ceka_termin
    end

    event :postpone do
      transitions from: :rezervirano, to: :odgodio
    end

    event :cancel do
      transitions to: :odustao
    end

    event :finished do
      transitions from: [:doza_1, :doza_2, :doza_3], to: :gotovo
    end
  end

  def oib_nil?
    oib.nil?
  end

  def mbo_nil?
    mbo.nil?
  end
end
