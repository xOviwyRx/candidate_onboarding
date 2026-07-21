require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user, attributes) }

  let(:attributes) { {} }

  it "is valid with an email and a password" do
    expect(user).to be_valid
  end

  context "without an email" do
    let(:attributes) { { email: nil } }

    it "is NOT valid" do
      aggregate_failures do
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end
    end
  end

  context "when the email is not a valid address" do
    let(:attributes) { { email: "anna-at-example" } }

    it "is NOT valid" do
      aggregate_failures do
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("is invalid")
      end
    end
  end

  describe "email normalization" do
    context "when the email contains capitals" do
      let(:attributes) { { email: "Anna@Example.COM" } }

      it "downcases it, so signing in does not depend on how it was typed" do
        user.validate

        expect(user.email).to eq("anna@example.com")
      end
    end

    context "when the email is padded with whitespace" do
      let(:attributes) { { email: "  anna@example.com  " } }

      it "strips it" do
        user.validate

        expect(user.email).to eq("anna@example.com")
      end
    end
  end

  # Guards the factory: setting password_digest directly would build a user
  # whose authenticate always fails.
  describe "#authenticate" do
    subject(:user) { create(:user, password: "secret123") }

    it "returns the user when the password is correct" do
      expect(user.authenticate("secret123")).to eq(user)
    end
  end
end
