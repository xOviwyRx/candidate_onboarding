class User < ApplicationRecord
  has_secure_password

  has_one :candidate_profile
  has_many :candidate_documents, dependent: :destroy

  before_validation { self.email = email.strip.downcase if email.present? }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
