require "rails_helper"

RSpec.describe CvParser::TextExtractor do
  it "reads text out of a PDF" do
    document = create(:candidate_document, :parsable_pdf)

    expect(described_class.new(document).call).to include("Mondzorgkunde")
  end

  it "reads text out of a DOCX" do
    document = create(:candidate_document, :parsable_docx)

    expect(described_class.new(document).call).to include("Mondzorgkunde")
  end

  it "refuses a format it cannot read" do
    document = build(:candidate_document, :word_document)

    expect { described_class.new(document).call }.to raise_error(described_class::UnsupportedFormat)
  end
end
