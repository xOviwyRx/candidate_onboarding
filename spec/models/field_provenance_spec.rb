require "rails_helper"

RSpec.describe FieldProvenance do
  subject(:provenance) { described_class.new("email" => "anna@example.com", "first_name" => "Anna") }

  it "says a field matched on its shape came from the CV" do
    expect(provenance.label_for(:email)).to eq(described_class::EXTRACTED)
  end

  it "asks the candidate to check a field that was guessed from its position" do
    expect(provenance.label_for(:first_name)).to eq(described_class::CHECK)
  end

  it "marks a field the CV did not supply as missing" do
    expect(provenance.label_for(:city)).to eq(described_class::MISSING)
  end

  context "when no CV was parsed" do
    subject(:provenance) { described_class.new(nil) }

    it "labels nothing, because there is nothing to check" do
      expect(provenance.label_for(:email)).to be_nil
    end
  end
end
