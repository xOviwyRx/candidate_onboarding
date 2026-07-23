require "rails_helper"

RSpec.describe Skill, type: :model do
  subject { create(:skill) }

  it { is_expected.to have_many(:candidate_skills).dependent(:restrict_with_error) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  it "rejects a job function the platform does not offer" do
    skill = build(:skill, job_functions: %w[dental_assistant astronaut])
    skill.validate

    expect(skill.errors[:job_functions]).to include("contains invalid values: astronaut")
  end

  describe "#terms" do
    it "offers the name and every synonym to the CV parser" do
      skill = build(:skill, name: "Periodontology", synonyms: %w[parodontologie paro])

      expect(skill.terms).to eq(%w[Periodontology parodontologie paro])
    end
  end

  describe ".for_job_function" do
    it "returns only the skills belonging to that function" do
      hygiene = create(:skill, job_functions: %w[dental_hygienist])
      create(:skill, job_functions: %w[front_office])

      expect(described_class.for_job_function("dental_hygienist")).to contain_exactly(hygiene)
    end
  end
end
