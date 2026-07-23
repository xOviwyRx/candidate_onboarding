module CvParser
  # A year range as CVs write it: "2016 - 2019", "2019 – heden". Only years are
  # read; a CV that dates a row by month gets January, which is close enough for
  # a field the candidate reviews before saving.
  class DateRange
    PATTERN = /(\d{4})\s*[-–—]+\s*(\d{4}|heden|present|now|nu|current)/i
    OPEN_ENDED = /\A(?:heden|present|now|nu|current)\z/i

    def self.from(line)
      match = line.match(PATTERN)
      return if match.nil?

      finishes = match[2]

      { start_date: "#{match[1]}-01-01",
        end_date: ("#{finishes}-12-31" unless finishes.match?(OPEN_ENDED)),
        current: finishes.match?(OPEN_ENDED) }
    end
  end
end
