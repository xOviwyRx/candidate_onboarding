FactoryBot.define do
  factory :candidate_document do
    user
    document_type { "cv" }

    after(:build) do |document|
      document.file.attach(
        io: StringIO.new("%PDF-1.4 fake cv"),
        filename: "cv.pdf",
        content_type: "application/pdf"
      )
    end
  end
end
