module CvParser
  # Rows under the work experience heading. A row is only taken when it carries
  # a year range — that is what separates an entry from a bullet describing one.
  class WorkExperiences
    HEADING = /\A(?:werkervaring|work\sexperience|employment)\s*(?::\s*(.*))?\z/xi

    def initialize(text)
      @text = text.to_s
    end

    def call
      rows = Section.lines(text, HEADING).filter_map { |line| row_for(line) }

      rows.any? ? { work_experiences: rows } : {}
    end

    private

    attr_reader :text

    def row_for(line)
      dates = DateRange.from(line)
      return if dates.nil?

      fields = line.sub(DateRange::PATTERN, "").split(",").map(&:strip).reject(&:empty?)
      return if fields.empty?

      { job_title: fields[0], company_name: fields[1],
        start_date: dates[:start_date], end_date: dates[:end_date],
        current_job: dates[:current] }.compact
    end
  end
end
