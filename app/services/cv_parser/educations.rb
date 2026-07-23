module CvParser
  # Rows under the education heading, read the same way as work experience. The
  # level is taken off the front of the study when the CV states one, because
  # "HBO Mondzorgkunde" names both.
  class Educations
    HEADING = /\A(?:opleiding(?:en)?|education|studie)\s*(?::\s*(.*))?\z/xi
    LEVEL = /\A(mbo|hbo|bachelor|master|doctor|course|cursus)\b[\s:-]*/i
    SEPARATORS = /[,()·|—–]/

    DUTCH_LEVELS = { "cursus" => "course" }.freeze

    def initialize(text)
      @text = text.to_s
    end

    def call
      rows = Entries.from(Section.lines(text, HEADING)).filter_map { |entry| row_for(entry) }

      rows.any? ? { educations: rows } : {}
    end

    private

    attr_reader :text

    # "Bachelor — Mondzorgkunde" leaves a dash behind once the level comes off
    # the front.
    def strip_punctuation(value)
      value.sub(/\A[[:punct:]\s]+/, "").strip
    end

    # Work CVs put the job title above the employer, but education CVs usually
    # put the institution above the degree. The level word says which is which:
    # "Bachelor Mondzorgkunde" names a study, "Hogeschool Utrecht" does not.
    def split_study_and_institution(above, fields)
      return [ fields[0], fields[1] ] if above.blank?
      return [ fields[0], above ] if fields[0].to_s.match?(LEVEL)

      [ above, fields[0] ]
    end

    def row_for(entry)
      fields = entry[:line].sub(entry[:dates][:matched], "").split(SEPARATORS).map(&:strip).reject(&:empty?)
      study, institution = split_study_and_institution(entry[:title], fields)
      return if study.blank?

      level = study[LEVEL, 1]&.downcase

      { study: strip_punctuation(study.sub(LEVEL, "")), institution: institution,
        location: entry[:title] ? fields[1] : fields[2],
        level: DUTCH_LEVELS.fetch(level, level),
        start_date: entry[:dates][:start_date], end_date: entry[:dates][:end_date] }.compact
    end
  end
end
