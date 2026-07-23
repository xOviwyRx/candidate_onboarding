class CandidateProfile < ApplicationRecord
  belongs_to :user

  has_many :educations, dependent: :destroy
  has_many :work_experiences, dependent: :destroy
  has_many :candidate_languages, dependent: :destroy
  has_many :candidate_skills, dependent: :destroy
  has_many :skills, through: :candidate_skills

  accepts_nested_attributes_for :educations, reject_if: :all_blank
  accepts_nested_attributes_for :work_experiences, reject_if: :all_blank
  accepts_nested_attributes_for :candidate_languages, reject_if: :all_blank

  # §9's second consent gate, for a candidate who reached this form without
  # uploading a CV. Nil when the user has already consented, so the acceptance
  # validator skips it and the check box is not shown again.
  attr_accessor :consent

  validate :consent_accepted, on: :create, unless: -> { user&.consented? }

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

  PERCENTAGE_EMPLOYMENT_TYPES = %w[self_employed percentage_based].freeze

  BIG_JOB_FUNCTIONS = %w[general_dentist dental_hygienist specialist].freeze

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
  validates :candidate_languages, presence: true

  validate { validate_allowed_values(:preferred_regions, PREFERRED_REGIONS) }
  validate { validate_allowed_values(:employment_types, EMPLOYMENT_TYPES) }
  validate { validate_allowed_values(:available_working_days, WORKING_DAYS) }
  validate { validate_allowed_values(:transport_types, TRANSPORT_TYPES) }

  validates :desired_percentage, numericality: { in: 0..100 }, allow_nil: true
  validates :desired_gross_salary, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :average_daily_revenue, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validates :desired_gross_salary, presence: true, if: :salary_relevant?
  validates :desired_percentage, presence: true, if: :percentage_relevant?
  validates :big_registration_status, presence: true, if: :big_relevant?
  validates :big_number, presence: true, if: :registered?

  before_validation :clear_irrelevant_compensation

  def salary_relevant?
    employment_types.to_a.include?("employed")
  end

  def percentage_relevant?
    employment_types.to_a.intersect?(PERCENTAGE_EMPLOYMENT_TYPES)
  end

  def big_relevant?
    BIG_JOB_FUNCTIONS.include?(job_function)
  end

  # A BIG number only applies once the candidate says they are registered, so it
  # needs the status as well as the job function.
  def big_number_relevant?
    big_relevant? && registered?
  end

  private

  # The status is cleared before the number is checked, so big_number_relevant?
  # reads the value that will actually be saved.
  def clear_irrelevant_compensation
    self.desired_gross_salary = nil unless salary_relevant?
    self.desired_percentage = nil unless percentage_relevant?

    unless big_relevant?
      self.average_daily_revenue = nil
      self.big_registration_status = nil
    end

    self.big_number = nil unless big_number_relevant?
  end

  # acceptance: true would skip a nil value, letting a request that omits the
  # parameter through. Only asked of a candidate who has not consented already.
  def consent_accepted
    return if ActiveModel::Type::Boolean.new.cast(consent)

    errors.add(:consent, "must be accepted before saving your profile")
  end

  def validate_allowed_values(attribute, allowed)
    invalid = public_send(attribute).to_a - allowed
    return if invalid.empty?

    errors.add(attribute, "contains invalid values: #{invalid.join(', ')}")
  end
end
