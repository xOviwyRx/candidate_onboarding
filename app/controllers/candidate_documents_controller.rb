class CandidateDocumentsController < ApplicationController
  before_action :require_sign_in

  def new
    @candidate_document = current_user.candidate_documents.new
  end

  def create
    @candidate_document = current_user.candidate_documents.new(
      document_type: "cv", consent: params.dig(:candidate_document, :consent)
    )
    @candidate_document.file.attach(params.dig(:candidate_document, :file))

    if @candidate_document.save
      current_user.record_consent
      ParseCandidateCvJob.perform_later(@candidate_document)
      redirect_to @candidate_document
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @candidate_document = current_user.candidate_documents.find(params[:id])
  end

  # §9: scoped to the signed-in candidate, so another user's id raises
  # RecordNotFound and returns 404 rather than the file. Held in memory rather
  # than streamed, which the 25 MB upload cap keeps reasonable.
  def file
    document = current_user.candidate_documents.find(params[:id])

    send_data document.file.download,
              filename: document.original_filename,
              type: document.content_type,
              disposition: "inline"
  end
end
