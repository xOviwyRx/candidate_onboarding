FactoryBot.define do
  factory :candidate_document do
    transient do
      filename { "cv.pdf" }
      file_content_type { "application/pdf" }
      file_bytes { 1.kilobyte }
      fixture { nil }
    end

    user
    document_type { "cv" }

    after(:build) do |document, evaluator|
      io = if evaluator.fixture
        Rails.root.join("spec/fixtures/files", evaluator.fixture).open
      else
        StringIO.new("x" * evaluator.file_bytes)
      end

      document.file.attach(
        io: io,
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

    # Real files, so the text extractor has something it can actually read.
    trait :parsable_pdf do
      fixture { "cv.pdf" }
    end

    trait :parsable_docx do
      office_open_xml
      fixture { "cv.docx" }
    end

    trait :unsupported_type do
      filename { "cv.txt" }
      file_content_type { "text/plain" }
    end
  end
end
