require "rails_helper"

RSpec.describe WorkExperience, type: :model do
  subject(:work_experience) { build(:work_experience) }

  it { is_expected.to belong_to(:candidate_profile) }

  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:company_name) }

  describe "date order" do
    it "rejects an end date before the start date" do
      work_experience = build(:work_experience, start_date: Date.new(2020, 9, 1), end_date: Date.new(2019, 9, 1))

      expect(work_experience).not_to be_valid
    end

    it "accepts a current job with no end date" do
      expect(build(:work_experience, :current)).to be_valid
    end
  end
end
