require "rails_helper"

RSpec.describe Education, type: :model do
  subject(:education) { build_stubbed(:education, attributes) }

  let(:attributes) { {} }

  it "is valid with a study, a level and a start and end date" do
    expect(education).to be_valid
  end

  context "without a candidate profile" do
    let(:attributes) { { candidate_profile: nil } }

    it "is NOT valid" do
      aggregate_failures do
        expect(education).not_to be_valid
        expect(education.errors[:candidate_profile]).to include("must exist")
      end
    end
  end

  context "without a study" do
    let(:attributes) { { study: nil } }

    it "is NOT valid" do
      aggregate_failures do
        expect(education).not_to be_valid
        expect(education.errors[:study]).to include("can't be blank")
      end
    end
  end

  context "when the level is blank" do
    let(:attributes) { { level: "" } }

    it "is valid, because an empty select submits a blank rather than nil" do
      expect(education).to be_valid
    end
  end

  context "when the level is outside the allowed list" do
    let(:attributes) { { level: "phd" } }

    it "is NOT valid" do
      aggregate_failures do
        expect(education).not_to be_valid
        expect(education.errors[:level]).to include("is not included in the list")
      end
    end
  end

  context "when the end date equals the start date" do
    let(:attributes) { { start_date: Date.new(2020, 9, 1), end_date: Date.new(2020, 9, 1) } }

    it "is valid, because a course can start and finish on the same day" do
      expect(education).to be_valid
    end
  end

  context "when the end date is before the start date" do
    let(:attributes) { { start_date: Date.new(2020, 9, 1), end_date: Date.new(2019, 9, 1) } }

    it "is NOT valid" do
      aggregate_failures do
        expect(education).not_to be_valid
        expect(education.errors[:end_date]).to include("must be after the start date")
      end
    end
  end

  context "with only a start date" do
    let(:attributes) { { start_date: Date.new(2020, 9, 1), end_date: nil } }

    it "is valid" do
      expect(education).to be_valid
    end
  end

  context "with only an end date" do
    let(:attributes) { { start_date: nil, end_date: Date.new(2020, 9, 1) } }

    it "is valid" do
      expect(education).to be_valid
    end
  end
end
