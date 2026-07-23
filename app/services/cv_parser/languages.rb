module CvParser
  # Languages are only read from the CV's own languages section. The same words
  # appear throughout a CV — "Duitsland", "German clinic" — so matching anywhere
  # else would collect places and employers instead.
  class Languages
    # Keyed by the name the platform seeds, so the controller can resolve a row
    # to a Language record without a second translation step.
    TERMS = {
      "Dutch" => /\b(?:nederlands|dutch)\b/i,
      "English" => /\b(?:engels|english)\b/i,
      "German" => /\b(?:duits|german|deutsch)\b/i,
      "French" => /\b(?:frans|french)\b/i,
      "Spanish" => /\b(?:spaans|spanish)\b/i,
      "Italian" => /\b(?:italiaans|italian)\b/i,
      "Portuguese" => /\b(?:portugees|portuguese)\b/i,
      "Polish" => /\b(?:pools|polish)\b/i,
      "Romanian" => /\b(?:roemeens|romanian)\b/i,
      "Turkish" => /\b(?:turks|turkish)\b/i,
      "Arabic" => /\b(?:arabisch|arabic)\b/i,
      "Ukrainian" => /\b(?:oekra[iï]ens|ukrainian)\b/i,
      "Russian" => /\b(?:russisch|russian)\b/i
    }.freeze

    # Either a heading on its own line, or "Languages: Dutch, English" with the
    # content inline. The colon is what makes the inline form unambiguous — it
    # stops a sentence beginning "Languages spoken at work" being read as one.
    SECTION = /\A(?:talen|languages|taalvaardigheid|language skills|talenkennis)\s*(?::\s*(.*))?\z/i
    # \s rather than a literal space: /x strips whitespace inside the pattern,
    # which would otherwise turn "work experience" into "workexperience".
    NEXT_SECTION = /\A(?:werkervaring|work\sexperience|opleiding(?:en)?|education|
                       vaardigheden|skills|profiel|profile|competenties|cursussen)\s*:?\z/xi

    LEVEL = /\b(a1|a2|b1|b2|c1|c2|moedertaal|native)\b/i
    LEVEL_WINDOW = 25

    def initialize(text)
      @text = text.to_s
    end

    def call
      return {} if section.blank?

      rows = TERMS.filter_map { |name, term| row_for(name, term) }

      rows.any? ? { languages: rows } : {}
    end

    private

    attr_reader :text

    def section
      @section ||= begin
        lines = text.lines.map(&:strip)
        start = lines.index { |line| line.match?(SECTION) }

        if start
          inline = lines[start][SECTION, 1].to_s
          following = lines[(start + 1)..].take_while { |line| !line.match?(NEXT_SECTION) }

          ([ inline ] + following).join("\n")
        end
      end
    end

    # The level is read from just after the language's own name, so that
    # "Nederlands (moedertaal), Engels (C1)" gives each its own.
    def row_for(name, term)
      found = section.match(term)
      return if found.nil?

      level = section[found.end(0), LEVEL_WINDOW].to_s[LEVEL, 1]&.downcase

      { name: name, level: level == "moedertaal" ? "native" : level }.compact
    end
  end
end
