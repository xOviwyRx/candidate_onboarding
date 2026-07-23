module CvParser
  # Rows under the work experience heading. A row needs a date before it counts
  # as an entry — that is what separates one from a bullet describing it.
  class WorkExperiences
    HEADING = /\A(?:werkervaring|work\sexperience|employment)\s*(?::\s*(.*))?\z/xi

    # CVs separate a company from its location with any of these.
    SEPARATORS = /[,()·|—–]/

    def initialize(text)
      @text = text.to_s
    end

    def call
      rows = Entries.from(Section.lines(text, HEADING)).filter_map { |entry| row_for(entry) }

      rows.any? ? { work_experiences: rows } : {}
    end

    private

    attr_reader :text

    # With a title on the line above, the dated line holds only the company.
    # Without one, the dated line holds both, in that order.
    def row_for(entry)
      fields = entry[:line].sub(entry[:dates][:matched], "").split(SEPARATORS).map(&:strip).reject(&:empty?)
      job_title = entry[:title] || fields[0]
      company_name = entry[:title] ? fields[0] : fields[1]
      return if job_title.blank?

      { job_title: job_title, company_name: company_name,
        start_date: entry[:dates][:start_date], end_date: entry[:dates][:end_date],
        current_job: entry[:dates][:current] }.compact
    end
  end
end
