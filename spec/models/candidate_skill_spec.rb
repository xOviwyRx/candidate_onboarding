require "rails_helper"

RSpec.describe CandidateSkill, type: :model do
  subject { create(:candidate_profile, skills: [ create(:skill) ]).candidate_skills.first }

  it { is_expected.to belong_to(:candidate_profile) }
  it { is_expected.to belong_to(:skill) }
  it { is_expected.to validate_uniqueness_of(:skill_id).scoped_to(:candidate_profile_id) }
end
