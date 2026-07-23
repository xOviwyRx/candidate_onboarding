module CvParser
  # A year range as CVs write it: "2016 - 2019", "2019 – heden". Only years are
  # read; a CV that dates a row by month gets January, which is close enough for
  # a field the candidate reviews before saving.
  class DateRange
    # CVs often write "Jan 2024 – Mar 2025". The month is skipped rather than
    # read: it varies by language, and the year alone is enough for a field the
    # candidate reviews. It cannot swallow "present" — the year group would then
    # fail and the match backtracks with the month empty.
    MONTH = /(?:[[:alpha:]]{3,10}\.?\s+)?/

    PATTERN = /(\d{4})\s*[-–—\/]+\s*#{MONTH}(\d{4}|heden|present|now|nu|current)/i
    OPEN_ENDED = /\A(?:heden|present|now|nu|current)\z/i

    # A lone year, as education entries are usually dated: "Mondzorgkunde, 2016".
    SINGLE_YEAR = /(?<!\d)(19|20)\d{2}(?!\d)/

    def self.from(line)
      range(line) || single_year(line)
    end

    def self.range(line)
      match = line.match(PATTERN)
      return if match.nil?

      finishes = match[2]

      { start_date: "#{match[1]}-01-01",
        end_date: ("#{finishes}-12-31" unless finishes.match?(OPEN_ENDED)),
        current: finishes.match?(OPEN_ENDED),
        matched: match[0] }
    end

    # Read as the year the row finished, which is what a single date on an
    # education line means. No start date is invented for it.
    def self.single_year(line)
      match = line.match(SINGLE_YEAR)
      return if match.nil?

      { end_date: "#{match[0]}-12-31", current: false, matched: match[0] }
    end
  end
end
