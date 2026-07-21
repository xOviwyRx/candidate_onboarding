require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to have_one(:candidate_profile) }
  it { is_expected.to have_secure_password }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to allow_value("anna@example.com").for(:email) }
  it { is_expected.not_to allow_value("anna-at-example").for(:email) }

  describe "email normalization" do
    it "downcases and strips the email, so signing in does not depend on how it was typed" do
      user = build(:user, email: "  Anna@Example.COM  ")
      user.validate

      expect(user.email).to eq("anna@example.com")
    end
  end
end
