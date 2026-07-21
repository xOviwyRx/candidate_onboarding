require "rails_helper"

RSpec.describe "CandidateDocuments", type: :request do
  let(:user) { create(:user) }

  def sign_in(user)
    post session_path, params: { email: user.email, password: "secret123" }
  end

  def cv_upload(filename: "cv.pdf", content_type: "application/pdf", bytes: 1.kilobyte)
    Rack::Test::UploadedFile.new(StringIO.new("x" * bytes), content_type, original_filename: filename)
  end

  describe "GET /candidate_documents/new" do
    it "redirects a visitor who is not signed in" do
      get new_candidate_document_path

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the upload form for a signed in candidate" do
      sign_in(user)

      get new_candidate_document_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /candidate_documents" do
    before { sign_in(user) }

    it "stores the uploaded CV against the signed in candidate" do
      expect {
        post candidate_documents_path, params: { candidate_document: { file: cv_upload } }
      }.to change(user.candidate_documents, :count).by(1)
    end

    it "redirects to the uploaded document" do
      post candidate_documents_path, params: { candidate_document: { file: cv_upload } }

      expect(response).to redirect_to(CandidateDocument.last)
    end

    it "records the document as pending, ready to be parsed" do
      post candidate_documents_path, params: { candidate_document: { file: cv_upload } }

      expect(CandidateDocument.last).to be_pending
    end

    it "rejects a file type the platform does not accept" do
      expect {
        post candidate_documents_path,
             params: { candidate_document: { file: cv_upload(filename: "cv.txt", content_type: "text/plain") } }
      }.not_to change(CandidateDocument, :count)
    end

    it "re-renders the form when no file was chosen" do
      post candidate_documents_path, params: { candidate_document: {} }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /candidate_documents/:id" do
    it "shows the candidate their own document" do
      sign_in(user)
      document = create(:candidate_document, user: user)

      get candidate_document_path(document)

      expect(response).to have_http_status(:ok)
    end

    it "does NOT expose a document belonging to another candidate" do
      sign_in(user)
      someone_elses = create(:candidate_document)

      get candidate_document_path(someone_elses)

      expect(response).to have_http_status(:not_found)
    end
  end
end
