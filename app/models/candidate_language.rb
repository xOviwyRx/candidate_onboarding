class CandidateLanguage < ApplicationRecord
  # CEFR plus "native", which §3.1 names alongside B2 as a level candidates use.
  LEVEL_LABELS = {
    "a1" => "A1", "a2" => "A2", "b1" => "B1",
    "b2" => "B2", "c1" => "C1", "c2" => "C2", "native" => "Native"
  }.freeze

  LEVELS = LEVEL_LABELS.keys.freeze

  belongs_to :candidate_profile
  belongs_to :language

  validates :level, inclusion: { in: LEVELS }, allow_blank: true
  validates :language_id, uniqueness: { scope: :candidate_profile_id }
end
