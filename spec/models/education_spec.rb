require "rails_helper"

RSpec.describe Education, type: :model do
  subject(:education) { build(:education) }

  it { is_expected.to belong_to(:candidate_profile) }

  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_inclusion_of(:level).in_array(described_class::LEVELS).allow_blank }

  describe "date order" do
    it "accepts a study that starts and finishes on the same day" do
      education = build(:education, start_date: Date.new(2020, 9, 1), end_date: Date.new(2020, 9, 1))

      expect(education).to be_valid
    end

    it "rejects an end date before the start date" do
      education = build(:education, start_date: Date.new(2020, 9, 1), end_date: Date.new(2019, 9, 1))

      expect(education).not_to be_valid
    end

    it "accepts a study with no dates at all" do
      education = build(:education, start_date: nil, end_date: nil)

      expect(education).to be_valid
    end
  end
end
