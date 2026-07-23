require "rails_helper"

RSpec.describe CandidateLanguage, type: :model do
  subject { create(:candidate_profile).candidate_languages.first }

  it { is_expected.to belong_to(:candidate_profile) }
  it { is_expected.to belong_to(:language) }
  it { is_expected.to validate_inclusion_of(:level).in_array(described_class::LEVELS).allow_blank }
  it { is_expected.to validate_uniqueness_of(:language_id).scoped_to(:candidate_profile_id) }
end
