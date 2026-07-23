class User < ApplicationRecord
  has_secure_password

  has_one :candidate_profile
  has_many :candidate_documents, dependent: :destroy

  before_validation { self.email = email.strip.downcase if email.present? }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def consented?
    consent_given_at.present?
  end

  # §9 asks for consent before uploading or saving, whichever the candidate
  # reaches first. It is recorded once and not asked for again.
  def record_consent
    update!(consent_given_at: Time.current) unless consented?
  end
end
