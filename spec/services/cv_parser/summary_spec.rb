require "rails_helper"

RSpec.describe CvParser::Summary do
  it "reads the section under its own heading" do
    text = "Sanne Bakker\n\nProfiel\n\nMondhygienist met 7 jaar ervaring.\n\nWerkervaring\n2019 - heden"

    expect(described_class.new(text).call)
      .to eq(professional_summary: "Mondhygienist met 7 jaar ervaring.")
  end

  it "joins a summary spread over several lines into one paragraph" do
    text = "SUMMARY\nDental hygienist with seven years in practice.\nFocused on prevention.\n\nSKILLS\nScaling"

    expect(described_class.new(text).call)
      .to eq(professional_summary: "Dental hygienist with seven years in practice. Focused on prevention.")
  end

  it "reads a heading written inline with its own content" do
    expect(described_class.new("Profile: Enthusiastic dental assistant.\n\nSkills\nPrevention").call)
      .to eq(professional_summary: "Enthusiastic dental assistant.")
  end

  it "stops before the next section" do
    text = "Profiel\nTandarts.\n\nOpleiding\nACTA 2015"

    expect(described_class.new(text).call).to eq(professional_summary: "Tandarts.")
  end

  it "returns nothing when the CV has no summary section" do
    expect(described_class.new("Werkervaring\nTandarts 2015").call).to be_empty
  end
end
