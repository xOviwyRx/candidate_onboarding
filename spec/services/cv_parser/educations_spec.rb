require "rails_helper"

RSpec.describe CvParser::Educations do
  it "takes the level off the front of the study when the CV states one" do
    text = "Opleiding\n2012 - 2016, HBO Mondzorgkunde, Hogeschool Utrecht"

    expect(described_class.new(text).call).to eq(educations: [
      { study: "Mondzorgkunde", institution: "Hogeschool Utrecht", level: "hbo",
        start_date: "2012-01-01", end_date: "2016-12-31" }
    ])
  end

  it "reads the Dutch word for a course as the platform's own level" do
    text = "Opleiding\n2019 - 2020, Cursus Implantologie, ACTA, Amsterdam"

    expect(described_class.new(text).call[:educations].first)
      .to include(level: "course", study: "Implantologie", location: "Amsterdam")
  end

  it "keeps a study whose level the CV does not state" do
    text = "Education\n2012 - 2016, Mondzorgkunde, Hogeschool Utrecht"

    expect(described_class.new(text).call[:educations].first).to eq(
      study: "Mondzorgkunde", institution: "Hogeschool Utrecht",
      start_date: "2012-01-01", end_date: "2016-12-31"
    )
  end

  it "tells study from institution when they sit on separate lines" do
    text = "EDUCATION\nHogeschool Utrecht\nBachelor Mondzorgkunde, 2016"

    expect(described_class.new(text).call).to eq(educations: [
      { study: "Mondzorgkunde", institution: "Hogeschool Utrecht",
        level: "bachelor", end_date: "2016-12-31" }
    ])
  end

  it "reads a lone year as the year the study finished" do
    expect(described_class.new("Education\nMondzorgkunde, Hogeschool Utrecht, 2016").call[:educations].first)
      .to include(end_date: "2016-12-31")
  end

  it "drops the punctuation left behind when the level is removed" do
    text = "Education\nBachelor — Mondzorgkunde\nHogeschool Utrecht, 2016"

    expect(described_class.new(text).call[:educations].first)
      .to include(study: "Mondzorgkunde", institution: "Hogeschool Utrecht", level: "bachelor")
  end

  it "returns nothing when the CV has no education section" do
    expect(described_class.new("Werkervaring\n2019 - 2021, Tandarts, ACTA").call).to be_empty
  end
end
