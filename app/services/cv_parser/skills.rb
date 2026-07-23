module CvParser
  # §3.6: skills found in the CV are matched against the platform's own list
  # rather than collected as free text, so they line up with the check boxes on
  # the form. Scoped to the CV's skills section for the same reason as languages
  # — "prevention" in a job description is a duty, not a claimed skill.
  class Skills
    SECTION = /\A(?:vaardigheden|skills|competenties|expertise|kwaliteiten)\s*(?::\s*(.*))?\z/i
    NEXT_SECTION = /\A(?:werkervaring|work\sexperience|opleiding(?:en)?|education|
                       talen|languages|profiel|profile|cursussen|certificaten)\s*:?\z/xi

    def initialize(text)
      @text = text.to_s
    end

    def call
      return {} if section.blank?

      names = Skill.order(:name).select { |skill| matches?(skill) }.map(&:name)

      names.any? ? { skills: names } : {}
    end

    private

    attr_reader :text

    # Regexp.escape because a seeded name can carry punctuation: "CAD/CAM".
    def matches?(skill)
      skill.terms.any? { |term| section.match?(/\b#{Regexp.escape(term)}\b/i) }
    end

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
  end
end
