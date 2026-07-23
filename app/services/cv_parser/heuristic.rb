module CvParser
  # Reads the CV's text and picks out what it can recognise. Named for what it
  # is: heuristics, not comprehension. Fields it cannot find are left out, so
  # the candidate supplies them in the review step.
  class Heuristic
    def initialize(candidate_document)
      @candidate_document = candidate_document
    end

    def call
      Patterns.new(text).call
    end

    private

    attr_reader :candidate_document

    def text
      TextExtractor.new(candidate_document).call
    end
  end
end
