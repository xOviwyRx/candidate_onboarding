require "rails_helper"

RSpec.describe CvParser::BigStatus do
  {
    "BIG geregistreerd sinds 2016" => "registered",
    "BIG registered" => "registered",
    "BIG-registratie: in aanvraag" => "in_progress",
    "BIG registration in progress" => "in_progress",
    "BIG: onder supervisie" => "under_supervision",
    "BIG-registratie: n.v.t." => "not_applicable"
  }.each do |text, expected|
    it "reads #{text.inspect} as #{expected}" do
      expect(described_class.new(text).call).to eq(big_registration_status: expected)
    end
  end

  it "recognises every status the platform offers" do
    expect(described_class::TERMS.keys).to match_array(CandidateProfile.big_registration_statuses.keys)
  end

  it "does NOT read a status out of a BIG number alone" do
    expect(described_class.new("BIG-nummer: 89123456789").call).to be_empty
  end

  it "returns nothing when the CV never mentions BIG" do
    expect(described_class.new("Tandarts met 7 jaar ervaring").call).to be_empty
  end
end
