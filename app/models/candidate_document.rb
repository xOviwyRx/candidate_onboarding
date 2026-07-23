class CandidateDocument < ApplicationRecord
  CONTENT_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  DEFAULT_MAX_FILE_SIZE_MB = 25

  belongs_to :user
  belongs_to :candidate_profile, optional: true

  has_one_attached :file

  enum :document_type, { cv: "cv" }, validate: true

  enum :parsing_status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }, validate: true

  # §9 requires consent before the CV is processed. Consent belongs to the person
  # rather than the file, so it is stored on the user; the document only carries
  # it far enough to be validated alongside the rest of the form.
  attr_accessor :consent

  before_validation :extract_file_metadata, if: -> { file.attached? }

  validate :consent_accepted

  validates :file, presence: true
  validates :original_filename, presence: true
  validates :content_type, presence: true, inclusion: { in: CONTENT_TYPES }
  validates :file_size,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: ->(_) { max_file_size } }

  def self.max_file_size
    ENV.fetch("MAX_CV_FILE_SIZE_MB", DEFAULT_MAX_FILE_SIZE_MB).to_i.megabytes
  end

  private

  # acceptance: true would skip a nil value, so a request that omits the
  # parameter would pass unchecked. §9's gate has to reject that too.
  def consent_accepted
    return if ActiveModel::Type::Boolean.new.cast(consent)

    errors.add(:consent, "must be accepted before uploading your CV")
  end

  def extract_file_metadata
    self.original_filename = file.filename.to_s
    self.content_type = file.content_type
    self.file_size = file.byte_size
  end
end
