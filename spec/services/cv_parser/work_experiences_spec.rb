require "rails_helper"

RSpec.describe CvParser::WorkExperiences do
  it "reads a row per job, and marks an open-ended one as current" do
    text = <<~CV
      Werkervaring
      2019 - heden, Mondhygienist, Tandartspraktijk Centrum
      2016 - 2019, Preventieassistent, Dental Clinic Amsterdam
    CV

    expect(described_class.new(text).call).to eq(work_experiences: [
      { job_title: "Mondhygienist", company_name: "Tandartspraktijk Centrum",
        start_date: "2019-01-01", current_job: true },
      { job_title: "Preventieassistent", company_name: "Dental Clinic Amsterdam",
        start_date: "2016-01-01", end_date: "2019-12-31", current_job: false }
    ])
  end

  it "skips a line describing a job rather than naming one" do
    text = "Work Experience\n2019 - 2021, Dental Assistant, Praktijk Noord\nResponsible for sterilization"

    expect(described_class.new(text).call[:work_experiences].length).to eq(1)
  end

  it "stops at the next section" do
    text = "Werkervaring\n2019 - 2021, Tandarts, ACTA\n\nOpleiding\n2012 - 2016, HBO Mondzorgkunde, HU"

    expect(described_class.new(text).call[:work_experiences].length).to eq(1)
  end

  it "reads an entry whose title sits on the line above its dates" do
    text = <<~CV
      WORK EXPERIENCE
      Dental Hygienist
      Tandartspraktijk Centrum (Utrecht · 2019 / present)
      Ran the periodontal programme and supervised two prevention assistants daily.
    CV

    expect(described_class.new(text).call).to eq(work_experiences: [
      { job_title: "Dental Hygienist", company_name: "Tandartspraktijk Centrum",
        start_date: "2019-01-01", current_job: true }
    ])
  end

  it "reads a range whose years carry month names" do
    text = "Work Experience\nDental Assistant\nPraktijk Noord (Utrecht) | Jan 2020 – Mar 2023"

    expect(described_class.new(text).call[:work_experiences].first)
      .to include(start_date: "2020-01-01", end_date: "2023-12-31")
  end

  it "still reads an open-ended range written with a month" do
    text = "Work Experience\nDental Assistant\nPraktijk Noord | Sep 2019 – present"

    expect(described_class.new(text).call[:work_experiences].first)
      .to include(start_date: "2019-01-01", current_job: true)
  end

  it "returns nothing when the CV has no work experience section" do
    expect(described_class.new("Opleiding\n2012 - 2016, HBO Mondzorgkunde, HU").call).to be_empty
  end
end
