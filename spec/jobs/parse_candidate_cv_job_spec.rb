require "rails_helper"

RSpec.describe ParseCandidateCvJob, type: :job do
  subject(:parse) { described_class.new.perform(document) }

  let(:document) { create(:candidate_document, :parsable_pdf) }

  it "stores what the parser found" do
    parse

    expect(document.reload.parsed_data).to include("email" => "sanne.bakker@example.nl")
  end

  it "marks the document as completed" do
    parse

    expect(document.reload).to be_completed
  end

  it "records when the CV was parsed" do
    parse

    expect(document.reload.parsed_at).to be_present
  end

  context "when the parser raises" do
    before { allow(CvParser).to receive(:call).and_raise(StandardError, "unreadable") }

    it "marks the document as failed, so the candidate can continue manually" do
      expect { parse }.to raise_error(StandardError)

      expect(document.reload).to be_failed
    end
  end
end
