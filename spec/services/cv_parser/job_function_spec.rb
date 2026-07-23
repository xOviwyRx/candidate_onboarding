require "rails_helper"

RSpec.describe CvParser::JobFunction do
  {
    "Mondhygienist" => "dental_hygienist",
    "Dental Hygienist" => "dental_hygienist",
    "Tandarts" => "general_dentist",
    "Tandartsassistente" => "dental_assistant",
    "Preventieassistent" => "prevention_assistant",
    "Paro-preventieassistent" => "paro_prevention_assistant",
    "Praktijkmanager" => "practice_manager",
    "Orthodontist" => "specialist",
    "Baliemedewerker" => "front_office",
    "Dental Technician" => "dental_technician"
  }.each do |title, expected|
    it "reads #{title.inspect} as #{expected}" do
      expect(described_class.new("Sanne Bakker\n#{title}").call).to eq(job_function: expected)
    end
  end

  it "recognises every job function the platform offers" do
    expect(described_class::TERMS.keys).to match_array(CandidateProfile::JOB_FUNCTIONS)
  end

  it "does not take a practice name for a job function" do
    expect(described_class.new("Piet Jansen\nWerkervaring\n2019 Tandartspraktijk Centrum").call).to be_empty
  end

  it "returns nothing for a CV from outside dentistry" do
    expect(described_class.new("Sam Vos\nRuby on Rails backend developer").call).to be_empty
  end

  it "ignores a job title buried below the top of the CV" do
    text = "Piet Jansen\n" + ([ "Lorem ipsum" ] * 10).join("\n") + "\nTandarts"

    expect(described_class.new(text).call).to be_empty
  end
end
