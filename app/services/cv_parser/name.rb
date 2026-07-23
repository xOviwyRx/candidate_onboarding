module CvParser
  # A name has no recognisable shape, only a position: CVs put it at the top.
  # This reads the first few lines and takes the first that looks like a person
  # rather than a heading, a practice, or a line of contact details.
  class Name
    LINES_TO_CONSIDER = 5
    MAX_WORDS = 4

    # Dutch surnames carry lowercase particles: "Anna de Vries", "Jan van der Berg".
    PARTICLE = /(?:van|de|der|den|ten|ter|het|von|du|la)/
    WORD = /\p{Lu}\p{L}*(?:[-'’]\p{Lu}?\p{L}+)*/
    FULL_NAME = /\A(#{WORD})((?:\s+(?:#{PARTICLE}\s+)*#{WORD})+)\z/

    NOT_A_NAME = /curriculum|vitae|resume|\bcv\b|persoonlijke|personal|contact|profiel|profile|
                  praktijk|kliniek|clinic|centrum|dental|tandarts|holding|\bb\.?v\.?\b/xi

    def initialize(text)
      @text = text.to_s
    end

    def call
      candidate_lines.each do |line|
        match = line.match(FULL_NAME)
        next if match.nil?

        return { first_name: tidy(match[1]), last_name: tidy(match[2].strip) }
      end

      {}
    end

    private

    attr_reader :text

    def candidate_lines
      text.lines.map(&:strip).reject(&:empty?).first(LINES_TO_CONSIDER).reject do |line|
        line.match?(NOT_A_NAME) || line.match?(/\d|@/) || line.split.size > MAX_WORDS
      end
    end

    # CVs often set the name in capitals for design reasons; the candidate
    # should not have to retype it just to fix the case.
    def tidy(name)
      name == name.upcase ? name.split.map(&:capitalize).join(" ") : name
    end
  end
end
