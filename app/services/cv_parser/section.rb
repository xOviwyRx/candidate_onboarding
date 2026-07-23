module CvParser
  # Finds one section of a CV: everything under its heading, up to the next one.
  # Headings may stand alone or be written inline — "Languages: Dutch, English".
  class Section
    HEADINGS = /\A(?:werkervaring|work\sexperience|employment|opleiding(?:en)?|education|
                   vaardigheden|skills|competenties|talen|languages|taalvaardigheid|
                   profiel|profile|summary|samenvatting|cursussen|certificaten|
                   certificates|expertise|kwaliteiten)\s*:?\z/xi

    def self.lines(text, heading)
      all = text.to_s.lines.map(&:strip)
      start = all.index { |line| line.match?(heading) }
      return [] if start.nil?

      inline = all[start][heading, 1].to_s

      ([ inline ] + all[(start + 1)..].take_while { |line| !line.match?(HEADINGS) })
        .reject(&:empty?)
    end
  end
end
