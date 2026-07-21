class CandidateDocumentsController < ApplicationController
  before_action :require_sign_in

  def new
    @candidate_document = current_user.candidate_documents.new
  end

  def create
    @candidate_document = current_user.candidate_documents.new(document_type: "cv")
    @candidate_document.file.attach(params.dig(:candidate_document, :file))

    if @candidate_document.save
      ParseCandidateCvJob.perform_later(@candidate_document)
      redirect_to @candidate_document
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @candidate_document = current_user.candidate_documents.find(params[:id])
  end
end
