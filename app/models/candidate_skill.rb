class CandidateSkill < ApplicationRecord
  belongs_to :candidate_profile
  belongs_to :skill

  validates :skill_id, uniqueness: { scope: :candidate_profile_id }
end
