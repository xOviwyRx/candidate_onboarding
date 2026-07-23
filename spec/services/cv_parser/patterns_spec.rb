require "rails_helper"

RSpec.describe CvParser::Patterns do
  describe "email" do
    it "reads an address and downcases it" do
      expect(described_class.new("Email: Sanne.Bakker@Example.NL").call[:email])
        .to eq("sanne.bakker@example.nl")
    end
  end

  describe "phone number" do
    {
      "Telefoon: +31 6 24 55 88 12" => "+31 6 24 55 88 12",
      "Tel: 06-24558812" => "06-24558812",
      "T: +31 (0)6 12345678" => "+31 (0)6 12345678",
      "Phone: 0031 20 555 1234" => "0031 20 555 1234"
    }.each do |text, expected|
      it "reads #{text.inspect}" do
        expect(described_class.new(text).call[:phone_number]).to eq(expected)
      end
    end

    it "ignores digits that only look like a phone number" do
      expect(described_class.new("Geboren 01-02-1990, postcode 3512 JE").call)
        .not_to include(:phone_number)
    end
  end

  describe "BIG number" do
    [ "BIG-nummer: 89123456789", "BIG number 89123456789", "bignr.89123456789" ].each do |text|
      it "reads #{text.inspect}" do
        expect(described_class.new(text).call[:big_number]).to eq("89123456789")
      end
    end

    it "does not take the BIG number for a phone number" do
      fields = described_class.new("M: 06 12 34 56 78 | BIG: 89123456789").call

      expect(fields).to include(phone_number: "06 12 34 56 78", big_number: "89123456789")
    end
  end

  describe "years of experience" do
    {
      "Mondhygienist met 7 jaar ervaring" => 7.0,
      "5,5 jaar ervaring in de mondzorg" => 5.5,
      "10+ jaar werkervaring" => 10.0,
      "8 years of experience in dentistry" => 8.0
    }.each do |text, expected|
      it "reads #{text.inspect}" do
        expect(described_class.new(text).call[:years_of_experience]).to eq(expected)
      end
    end
  end

  it "returns nothing for a CV it cannot read anything out of" do
    expect(described_class.new("Curriculum Vitae").call).to be_empty
  end
end
