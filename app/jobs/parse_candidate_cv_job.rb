class ParseCandidateCvJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(candidate_document)
    candidate_document.processing!

    candidate_document.update!(
      parsed_data: CvParser.call(candidate_document),
      parsed_at: Time.current,
      parsing_status: :completed
    )
  rescue StandardError
    candidate_document.failed!
    raise
  end
end
