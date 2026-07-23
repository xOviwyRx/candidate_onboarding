class Language < ApplicationRecord
  has_many :candidate_languages, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
