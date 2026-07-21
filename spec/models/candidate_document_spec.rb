require "rails_helper"

RSpec.describe CandidateDocument, type: :model do
  subject(:document) { build(:candidate_document) }

  it "is valid with an attached PDF" do
    expect(document).to be_valid
  end

  context "without a file" do
    subject(:document) { build(:candidate_document).tap { |doc| doc.file.detach } }

    it "is NOT valid" do
      aggregate_failures do
        expect(document).not_to be_valid
        expect(document.errors[:file]).to include("can't be blank")
      end
    end
  end

  context "when the file is a Word document" do
    subject(:document) { build(:candidate_document, :word_document) }

    it "is valid" do
      expect(document).to be_valid
    end
  end

  context "when the file is an Office Open XML document" do
    subject(:document) { build(:candidate_document, :office_open_xml) }

    it "is valid" do
      expect(document).to be_valid
    end
  end

  context "when the file type is not accepted" do
    subject(:document) { build(:candidate_document, :unsupported_type) }

    it "is NOT valid" do
      aggregate_failures do
        expect(document).not_to be_valid
        expect(document.errors[:content_type]).to include("is not included in the list")
      end
    end
  end

  context "when the maximum size is one megabyte" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch)
        .with("MAX_CV_FILE_SIZE_MB", described_class::DEFAULT_MAX_FILE_SIZE_MB)
        .and_return(1)
    end

    context "and the file is exactly one megabyte" do
      subject(:document) { build(:candidate_document, file_bytes: 1.megabyte) }

      it "is valid, because the limit is inclusive" do
        expect(document).to be_valid
      end
    end

    context "and the file is one byte larger" do
      subject(:document) { build(:candidate_document, file_bytes: 1.megabyte + 1) }

      it "is NOT valid" do
        aggregate_failures do
          expect(document).not_to be_valid
          expect(document.errors[:file_size]).to include("must be less than or equal to #{1.megabyte}")
        end
      end
    end
  end

  context "without a candidate profile" do
    subject(:document) { build(:candidate_document, candidate_profile: nil) }

    it "is valid, because a CV is uploaded before the profile is created" do
      expect(document).to be_valid
    end
  end

  describe "file metadata" do
    subject(:document) do
      build(:candidate_document, filename: "anna-cv.pdf", file_bytes: 2.kilobytes)
    end

    it "copies the filename, content type and size from the attachment" do
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

    context "when MAX_CV_FILE_SIZE_MB is set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch)
          .with("MAX_CV_FILE_SIZE_MB", described_class::DEFAULT_MAX_FILE_SIZE_MB)
          .and_return(50)
      end

      it "uses the configured value" do
        expect(described_class.max_file_size).to eq(50.megabytes)
      end
    end
  end
end
