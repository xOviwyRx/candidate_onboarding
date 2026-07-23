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
    document = build(:candidate_document, :unsupported_type)

    expect { described_class.new(document).call }.to raise_error(described_class::UnsupportedFormat)
  end

  describe "a legacy DOC" do
    let(:document) { create(:candidate_document, :parsable_doc) }

    it "reads it by way of LibreOffice", if: CvParser::DocConverter.available? do
      expect(described_class.new(document).call).to include("Mondzorgkunde")
    end

    it "fails cleanly when LibreOffice is not installed, so the candidate can type it in" do
      allow(CvParser::DocConverter).to receive(:available?).and_return(false)

      expect { described_class.new(document).call }
        .to raise_error(described_class::UnsupportedFormat, /LibreOffice/)
    end
  end
end
