require "rails_helper"

RSpec.describe CvParser::Skills do
  before do
    create(:skill, name: "Periodontology", synonyms: %w[parodontologie])
    create(:skill, name: "Prevention", synonyms: %w[preventie])
    create(:skill, name: "CAD/CAM", synonyms: %w[cadcam])
  end

  it "matches the platform's own skill names" do
    expect(described_class.new("Skills\nPeriodontology and prevention").call)
      .to eq(skills: [ "Periodontology", "Prevention" ])
  end

  it "matches the Dutch spelling a CV is more likely to use" do
    expect(described_class.new("Vaardigheden\nParodontologie, preventie").call)
      .to eq(skills: [ "Periodontology", "Prevention" ])
  end

  it "matches a name carrying punctuation" do
    expect(described_class.new("Skills\nCAD/CAM").call).to eq(skills: [ "CAD/CAM" ])
  end

  it "reads a heading written inline with its own content" do
    expect(described_class.new("Skills: preventie").call).to eq(skills: [ "Prevention" ])
  end

  it "stops at the next section, so duties are not read as claimed skills" do
    text = "Skills\nPeriodontology\n\nWork Experience\nResponsible for prevention"

    expect(described_class.new(text).call).to eq(skills: [ "Periodontology" ])
  end

  it "returns nothing when the CV has no skills section" do
    expect(described_class.new("Work Experience\nPeriodontology daily").call).to be_empty
  end
end
