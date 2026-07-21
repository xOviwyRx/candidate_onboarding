require "rails_helper"

RSpec.describe CandidateDocument, type: :model do
  subject(:document) { build(:candidate_document) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:candidate_profile).optional }
  it { is_expected.to have_one_attached(:file) }

  it {
    is_expected.to define_enum_for(:parsing_status)
      .with_values(pending: "pending", processing: "processing", completed: "completed", failed: "failed")
      .backed_by_column_of_type(:string)
      .validating
  }

  describe "accepted files" do
    it "accepts a PDF" do
      expect(build(:candidate_document)).to be_valid
    end

    it "accepts a Word document" do
      expect(build(:candidate_document, :word_document)).to be_valid
    end

    it "accepts an Office Open XML document" do
      expect(build(:candidate_document, :office_open_xml)).to be_valid
    end

    it "rejects any other file type" do
      expect(build(:candidate_document, :unsupported_type)).not_to be_valid
    end

    it "rejects a document with no file attached" do
      expect(build(:candidate_document).tap { |doc| doc.file.detach }).not_to be_valid
    end
  end

  describe "file size" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch)
        .with("MAX_CV_FILE_SIZE_MB", described_class::DEFAULT_MAX_FILE_SIZE_MB)
        .and_return(1)
    end

    it "accepts a file of exactly the maximum size, because the limit is inclusive" do
      expect(build(:candidate_document, file_bytes: 1.megabyte)).to be_valid
    end

    it "rejects a file one byte over the maximum" do
      expect(build(:candidate_document, file_bytes: 1.megabyte + 1)).not_to be_valid
    end
  end

  describe "file metadata" do
    it "copies the filename, content type and size from the attachment" do
      document = build(:candidate_document, filename: "anna-cv.pdf", file_bytes: 2.kilobytes)
      document.validate

      aggregate_failures do
        expect(document.original_filename).to eq("anna-cv.pdf")
        expect(document.content_type).to eq("application/pdf")
        expect(document.file_size).to eq(2.kilobytes)
      end
    end
  end

  describe ".max_file_size" do
    it "defaults to 25 megabytes" do
      expect(described_class.max_file_size).to eq(25.megabytes)
    end

    it "uses MAX_CV_FILE_SIZE_MB when it is set" do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch)
        .with("MAX_CV_FILE_SIZE_MB", described_class::DEFAULT_MAX_FILE_SIZE_MB)
        .and_return(50)

      expect(described_class.max_file_size).to eq(50.megabytes)
    end
  end
end
