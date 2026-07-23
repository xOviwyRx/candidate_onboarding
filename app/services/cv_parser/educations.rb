module CvParser
  # Rows under the education heading, read the same way as work experience. The
  # level is taken off the front of the study when the CV states one, because
  # "HBO Mondzorgkunde" names both.
  class Educations
    HEADING = /\A(?:opleiding(?:en)?|education|studie)\s*(?::\s*(.*))?\z/xi
    LEVEL = /\A(mbo|hbo|bachelor|master|doctor|course|cursus)\b[\s:-]*/i

    def initialize(text)
      @text = text.to_s
    end

    def call
      rows = Section.lines(text, HEADING).filter_map { |line| row_for(line) }

      rows.any? ? { educations: rows } : {}
    end

    private

    attr_reader :text

    def row_for(line)
      dates = DateRange.from(line)
      return if dates.nil?

      fields = line.sub(DateRange::PATTERN, "").split(",").map(&:strip).reject(&:empty?)
      return if fields.empty?

      study = fields[0]
      level = study[LEVEL, 1]&.downcase

      { study: study.sub(LEVEL, ""), institution: fields[1], location: fields[2],
        level: level == "cursus" ? "course" : level,
        start_date: dates[:start_date], end_date: dates[:end_date] }.compact
    end
  end
end
