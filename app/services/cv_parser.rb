module CvParser
  def self.call(candidate_document)
    implementation.new(candidate_document).call
  end

  def self.implementation
    Stub
  end
end
