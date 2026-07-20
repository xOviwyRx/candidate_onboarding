class CandidateProfile < ApplicationRecord
  PHONE_NUMBER_FORMAT = /\A\+?[0-9\s\-()]{6,20}\z/

  JOB_FUNCTIONS = %w[
    general_dentist dental_hygienist dental_assistant prevention_assistant
    paro_prevention_assistant orthodontic_assistant front_office
    practice_manager dental_technician specialist
  ].freeze

  SEARCH_STATUSES = %w[active passive inactive].freeze

  WORKING_DAYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  TRANSPORT_TYPES = %w[bike scooter public_transport car].freeze

  enum :big_registration_status, {
    registered: "registered",
    in_progress: "in_progress",
    under_supervision: "under_supervision",
    not_applicable: "not_applicable"
  }, validate: { allow_nil: true }

  validates :first_name, :last_name, :city, presence: true
  validates :phone_number, presence: true, format: { with: PHONE_NUMBER_FORMAT, message: "must be a valid phone number" }

  before_validation { self.email = email.strip.downcase if email.present? }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :job_function, presence: true, inclusion: { in: JOB_FUNCTIONS }
  validates :search_status, presence: true, inclusion: { in: SEARCH_STATUSES }

  validates :max_travel_time, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :years_of_experience, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :available_from, presence: true

  validates :preferred_regions, presence: true
  validates :employment_types, presence: true
  validates :available_working_days, presence: true
  validate :available_working_days_valid

  validate :transport_types_valid

  validates :desired_percentage, numericality: { in: 0..100 }, allow_nil: true

  validates :big_number, presence: true, if: :registered?

  private

  def available_working_days_valid
    invalid = available_working_days - WORKING_DAYS
    errors.add(:available_working_days, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end

  def transport_types_valid
    invalid = transport_types - TRANSPORT_TYPES
    errors.add(:transport_types, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end
end
