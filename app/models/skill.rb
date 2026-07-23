class Skill < ApplicationRecord
  has_many :candidate_skills, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validate :job_functions_are_offered

  scope :for_job_function, ->(function) { where("job_functions @> ARRAY[?]::varchar[]", function) }

  private

  def job_functions_are_offered
    invalid = job_functions.to_a - CandidateProfile::JOB_FUNCTIONS
    return if invalid.empty?

    errors.add(:job_functions, "contains invalid values: #{invalid.join(', ')}")
  end
end
