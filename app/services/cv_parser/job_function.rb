module CvParser
  # Maps the words a CV actually uses onto CandidateProfile::JOB_FUNCTIONS.
  class JobFunction
    # Order matters: "tandartsassistente" contains "tandarts", and
    # "paro-preventieassistent" contains "preventieassistent". The most specific
    # term has to win, so the general dentist comes last.
    TERMS = {
      "paro_prevention_assistant" => /paro[\s-]?preventie[\s-]?assistent|paro[\s-]?prevention/i,
      "prevention_assistant" => /preventie[\s-]?assistent|prevention assistant/i,
      "orthodontic_assistant" => /orthodontie[\s-]?assistent|orthodontisch assistent|orthodontic assistant/i,
      "dental_assistant" => /tandarts[\s-]?assistent|dental assistant/i,
      "dental_hygienist" => /mondhygi[eë]nist|dental hygienist|hygi[eë]nist/i,
      "practice_manager" => /praktijk[\s-]?manager|practice manager/i,
      "dental_technician" => /tandtechnicus|tandtechniek|dental technician/i,
      "front_office" => /front[\s-]?office|receptionist|balie[\s-]?medewerker|baliemedewerk/i,
      "specialist" => /orthodontist|implantoloog|kaakchirurg|endodontoloog|parodontoloog/i,
      "general_dentist" => /\btandarts\b|general dentist|\bdentist\b/i
    }.freeze

    # Only the top of the CV, where the candidate states their own title. Further
    # down, the same words describe former employers and colleagues.
    LINES_TO_CONSIDER = 8

    def initialize(text)
      @text = text.to_s
    end

    def call
      { job_function: TERMS.find { |_, term| heading.match?(term) }&.first }.compact
    end

    private

    attr_reader :text

    def heading
      @heading ||= text.lines.map(&:strip).reject(&:empty?).first(LINES_TO_CONSIDER).join("\n")
    end
  end
end
