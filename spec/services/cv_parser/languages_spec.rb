require "rails_helper"

RSpec.describe CvParser::Languages do
  it "reads a level for each language listed on one line" do
    text = "Sanne Bakker\n\nTalen\n\nNederlands (moedertaal), Engels (C1), Duits (B1)"

    expect(described_class.new(text).call).to eq(languages: [
      { name: "Dutch", level: "native" },
      { name: "English", level: "c1" },
      { name: "German", level: "b1" }
    ])
  end

  it "stops at the next section, so employers are not read as languages" do
    text = "Languages\nDutch - native\nEnglish - B2\n\nWork Experience\nGerman clinic 2019"

    expect(described_class.new(text).call).to eq(languages: [
      { name: "Dutch", level: "native" },
      { name: "English", level: "b2" }
    ])
  end

  it "leaves the level out when the CV words it in a way the platform has no value for" do
    expect(described_class.new("Talen\nNederlands\nEngels vloeiend").call)
      .to eq(languages: [ { name: "Dutch" }, { name: "English" } ])
  end

  it "does not read a country as the language it is named after" do
    expect(described_class.new("Talen\nEngels\n\nWerkervaring\nTandarts in Duitsland").call)
      .to eq(languages: [ { name: "English" } ])
  end

  it "reads a heading written inline with its own content" do
    expect(described_class.new("SKILLS\nPreventie\n\nLanguages: Dutch — Native | German — B2 Advanced").call)
      .to eq(languages: [ { name: "Dutch", level: "native" }, { name: "German", level: "b2" } ])
  end

  it "does not read a sentence starting with the word as a heading" do
    expect(described_class.new("Languages spoken at work included English").call).to be_empty
  end

  it "returns nothing when the CV has no languages section" do
    expect(described_class.new("Werkervaring\nTandarts in Duitsland 2015").call).to be_empty
  end
end
