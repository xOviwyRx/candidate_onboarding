module CvParser
  # Returns the shape every parser implementation must produce, without reading
  # the file. Fields a CV does not contain are left out rather than guessed,
  # so the review form can tell "not found" from "found and empty".
  class Stub
    def initialize(candidate_document)
      @candidate_document = candidate_document
    end

    def call
      {
        first_name: "Anna",
        last_name: "de Vries",
        email: "anna.de.vries@example.com",
        phone_number: "+31 6 12345678",
        city: "Amsterdam",
        country: "Netherlands",
        job_function: "dental_hygienist",
        years_of_experience: 5,
        professional_summary: "Dental hygienist with five years of practice experience.",
        educations: [
          {
            institution: "Hogeschool Utrecht",
            study: "Mondzorgkunde",
            location: "Utrecht, Netherlands",
            level: "hbo",
            start_date: "2015-09-01",
            end_date: "2019-06-30"
          }
        ],
        work_experiences: [
          {
            job_title: "Dental Hygienist",
            company_name: "Tandartspraktijk Centrum",
            responsibilities: "Periodontal treatment, prevention and patient education.",
            start_date: "2019-09-01",
            end_date: nil,
            current_job: true
          }
        ],
        languages: [
          { name: "Dutch", level: "native" },
          { name: "English", level: "C1" }
        ],
        skills: %w[periodontology prevention patient_education]
      }
    end

    private

    attr_reader :candidate_document
  end
end
