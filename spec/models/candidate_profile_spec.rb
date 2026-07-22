require "rails_helper"

RSpec.describe CandidateProfile, type: :model do
  subject(:profile) { build(:candidate_profile) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:educations).dependent(:destroy) }
  it { is_expected.to have_many(:work_experiences).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:phone_number) }
  it { is_expected.to validate_presence_of(:available_from) }
  it { is_expected.to validate_presence_of(:preferred_regions) }
  it { is_expected.to validate_presence_of(:employment_types) }
  it { is_expected.to validate_presence_of(:available_working_days) }

  it { is_expected.to validate_inclusion_of(:job_function).in_array(described_class::JOB_FUNCTIONS) }
  it { is_expected.to validate_inclusion_of(:search_status).in_array(described_class::SEARCH_STATUSES) }

  it { is_expected.to validate_numericality_of(:max_travel_time).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:years_of_experience).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:desired_percentage).is_in(0..100).allow_nil }

  it { is_expected.to allow_value("+31 6 12345678").for(:phone_number) }
  it { is_expected.not_to allow_value("call me maybe").for(:phone_number) }

  describe "email normalization" do
    it "downcases and strips the email" do
      profile = build(:candidate_profile, email: "  Anna@Example.COM  ")
      profile.validate

      expect(profile.email).to eq("anna@example.com")
    end
  end

  describe "available working days" do
    it "rejects a day that does not exist" do
      profile = build(:candidate_profile, available_working_days: %w[monday funday])
      profile.validate

      expect(profile.errors[:available_working_days]).to include("contains invalid values: funday")
    end
  end

  describe "preferred regions" do
    it "rejects a region that is not a Dutch province" do
      profile = build(:candidate_profile, preferred_regions: %w[utrecht atlantis])
      profile.validate

      expect(profile.errors[:preferred_regions]).to include("contains invalid values: atlantis")
    end
  end

  describe "employment types" do
    it "rejects an employment type the platform does not offer" do
      profile = build(:candidate_profile, employment_types: %w[employed volunteering])
      profile.validate

      expect(profile.errors[:employment_types]).to include("contains invalid values: volunteering")
    end
  end

  describe "transport types" do
    it "rejects a transport the platform does not offer" do
      profile = build(:candidate_profile, transport_types: %w[car hovercraft])
      profile.validate

      expect(profile.errors[:transport_types]).to include("contains invalid values: hovercraft")
    end

    it "accepts an empty list, because transport type is the one optional multi-select" do
      expect(build(:candidate_profile, transport_types: [])).to be_valid
    end
  end

  describe "BIG registration" do
    it "requires a BIG number from a registered candidate" do
      profile = build(:candidate_profile, big_registration_status: "registered", big_number: nil)

      expect(profile).not_to be_valid
    end

    it "does NOT require a BIG number from a candidate whose registration is in progress" do
      profile = build(:candidate_profile, big_registration_status: "in_progress", big_number: nil)

      expect(profile).to be_valid
    end
  end
end
