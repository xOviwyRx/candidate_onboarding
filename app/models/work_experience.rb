class WorkExperience < ApplicationRecord
  belongs_to :candidate_profile

  validates :job_title, presence: true
  validates :company_name, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, "must be after the start date") if end_date < start_date
  end
end
