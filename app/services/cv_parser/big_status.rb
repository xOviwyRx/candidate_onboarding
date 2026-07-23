module CvParser
  # §5 asks for the BIG status "if present". Present means the CV says it — a
  # BIG number on its own is not read as a status, because inferring one would
  # be the inventing that §5 forbids.
  class BigStatus
    # Keyed by CandidateProfile's enum values, most specific first: a CV saying
    # "BIG-registratie: in aanvraag" also contains the word "registratie".
    TERMS = {
      "in_progress" => /big[^.\n]{0,30}(?:in\s*(?:aanvraag|behandeling|progress)|aangevraagd|pending)/i,
      "under_supervision" => /big[^.\n]{0,30}(?:onder\s+supervisie|under\s+supervision|supervisie)/i,
      "not_applicable" => /big[^.\n]{0,30}(?:niet\s+van\s+toepassing|not\s+applicable|n\.?v\.?t\.?)/i,
      "registered" => /big[\s\-]*(?:geregistreerd|registered)|geregistreerd\s+in\s+het\s+big/i
    }.freeze

    def initialize(text)
      @text = text.to_s
    end

    def call
      { big_registration_status: TERMS.find { |_, term| text.match?(term) }&.first }.compact
    end

    private

    attr_reader :text
  end
end
