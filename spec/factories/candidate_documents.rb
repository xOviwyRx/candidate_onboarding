FactoryBot.define do
  factory :candidate_document do
    transient do
      filename { "cv.pdf" }
      file_content_type { "application/pdf" }
      file_bytes { 1.kilobyte }
    end

    user
    document_type { "cv" }

    after(:build) do |document, evaluator|
      document.file.attach(
        io: StringIO.new("x" * evaluator.file_bytes),
        filename: evaluator.filename,
        content_type: evaluator.file_content_type
      )
    end

    trait :word_document do
      filename { "cv.doc" }
      file_content_type { "application/msword" }
    end

    trait :office_open_xml do
      filename { "cv.docx" }
      file_content_type { "application/vnd.openxmlformats-officedocument.wordprocessingml.document" }
    end

    trait :unsupported_type do
      filename { "cv.txt" }
      file_content_type { "text/plain" }
    end
  end
end
