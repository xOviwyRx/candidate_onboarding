require "rails_helper"

RSpec.describe Language, type: :model do
  subject { create(:language) }

  it { is_expected.to have_many(:candidate_languages).dependent(:restrict_with_error) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
