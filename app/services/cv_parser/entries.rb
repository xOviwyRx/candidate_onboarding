module CvParser
  # Turns the lines of a history section into entries. A CV either puts one on a
  # single line — "2016 - 2019, Assistant, Praktijk Noord" — or splits it, with
  # the title on its own line and the dates on the line below.
  class Entries
    # A title is short. Anything longer is prose describing an entry, not naming
    # one, which is what keeps bullet points from being read as job titles.
    MAX_TITLE_LENGTH = 80

    def self.from(lines)
      lines.each_with_index.filter_map do |line, index|
        dates = DateRange.from(line)
        next if dates.nil?

        { dates: dates, line: line, title: title_above(lines, index) }
      end
    end

    def self.title_above(lines, index)
      return if index.zero?

      previous = lines[index - 1]
      return if previous.length > MAX_TITLE_LENGTH
      return if DateRange.from(previous)

      previous
    end
  end
end
