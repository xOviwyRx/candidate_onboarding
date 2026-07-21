class Education < ApplicationRecord
  LEVELS = %w[mbo hbo bachelor master doctor course].freeze

  belongs_to :candidate_profile

  validates :study, presence: true
  validates :level, inclusion: { in: LEVELS }, allow_blank: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, "must be after the start date") if end_date < start_date
  end
end
