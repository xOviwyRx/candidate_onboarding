module CvParser
  def self.call(candidate_document)
    Heuristic.new(candidate_document).call
  end
end
