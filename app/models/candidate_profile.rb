class CandidateProfile < ApplicationRecord
  belongs_to :user

  has_many :educations, dependent: :destroy
  has_many :work_experiences, dependent: :destroy

  PHONE_NUMBER_FORMAT = /\A\+?[0-9\s\-()]{6,20}\z/

  JOB_FUNCTIONS = %w[
    general_dentist dental_hygienist dental_assistant prevention_assistant
    paro_prevention_assistant orthodontic_assistant front_office
    practice_manager dental_technician specialist
  ].freeze

  SEARCH_STATUSES = %w[active passive inactive].freeze

  WORKING_DAYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  TRANSPORT_TYPES = %w[bike scooter public_transport car].freeze

  PREFERRED_REGIONS = %w[
    drenthe flevoland friesland gelderland groningen limburg
    noord_brabant noord_holland overijssel utrecht zeeland zuid_holland
  ].freeze

  EMPLOYMENT_TYPES = %w[employed self_employed percentage_based].freeze

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

  validate { validate_allowed_values(:preferred_regions, PREFERRED_REGIONS) }
  validate { validate_allowed_values(:employment_types, EMPLOYMENT_TYPES) }
  validate { validate_allowed_values(:available_working_days, WORKING_DAYS) }
  validate { validate_allowed_values(:transport_types, TRANSPORT_TYPES) }

  validates :desired_percentage, numericality: { in: 0..100 }, allow_nil: true

  validates :big_number, presence: true, if: :registered?

  private

  def validate_allowed_values(attribute, allowed)
    invalid = public_send(attribute).to_a - allowed
    return if invalid.empty?

    errors.add(attribute, "contains invalid values: #{invalid.join(', ')}")
  end
end
