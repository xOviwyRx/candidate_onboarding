module CvParser
  # §5 lists a professional summary "if useful". It is the one field where the
  # CV's own words are the value, so the section's lines are joined into a
  # paragraph rather than picked apart.
  class Summary
    SECTION = /\A(?:profiel|profile|summary|samenvatting|over\smij|about\sme|
                   persoonlijk\sprofiel|professional\ssummary)\s*(?::\s*(.*))?\z/xi
    NEXT_SECTION = /\A(?:werkervaring|work\sexperience|opleiding(?:en)?|education|
                       vaardigheden|skills|talen|languages|competenties|cursussen|
                       certificaten|certificates)\s*:?\z/xi

    # A CV that never states another heading would otherwise hand over its whole
    # remaining text as the summary.
    MAX_LINES = 10

    def initialize(text)
      @text = text.to_s
    end

    def call
      summary = section.to_s.squish

      summary.present? ? { professional_summary: summary } : {}
    end

    private

    attr_reader :text

    def section
      lines = text.lines.map(&:strip)
      start = lines.index { |line| line.match?(SECTION) }
      return if start.nil?

      inline = lines[start][SECTION, 1].to_s
      following = lines[(start + 1)..].take_while { |line| !line.match?(NEXT_SECTION) }.first(MAX_LINES)

      ([ inline ] + following).join(" ")
    end
  end
end
