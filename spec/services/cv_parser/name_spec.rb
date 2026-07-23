require "rails_helper"

RSpec.describe CvParser::Name do
  {
    "Sanne Bakker\n\nMondhygienist" => { first_name: "Sanne", last_name: "Bakker" },
    "Curriculum Vitae\n\nAnna de Vries\nTandarts" => { first_name: "Anna", last_name: "de Vries" },
    "CV\nPersoonlijke gegevens\nJan van der Berg" => { first_name: "Jan", last_name: "van der Berg" },
    "Sophie O'Brien-Smit\nHygienist" => { first_name: "Sophie", last_name: "O'Brien-Smit" }
  }.each do |text, expected|
    it "reads #{text.lines.first.strip.inspect} and the lines below it" do
      expect(described_class.new(text).call).to eq(expected)
    end
  end

  it "puts a name set in capitals back into normal case" do
    expect(described_class.new("MARIEKE JANSEN\nDental Assistant").call)
      .to eq(first_name: "Marieke", last_name: "Jansen")
  end

  it "does not take a practice name for a candidate's name" do
    expect(described_class.new("Tandartspraktijk Centrum\nWerkervaring").call).to be_empty
  end

  it "returns nothing when the top of the CV holds no name" do
    expect(described_class.new("Email: someone@example.com\n2019 - 2021").call).to be_empty
  end
end
