# §2 asks for a small label on each field saying where its value came from.
# Only fields the parser can fill are labelled; the rest of the form is ordinary
# input and marking it "Missing" would be noise.
class FieldProvenance
  # Read by matching a shape or an exact token, so a value is either right or
  # absent: an email, a phone number, an eleven-digit BIG number.
  CONFIDENT = %w[email phone_number big_number].freeze

  # Read by position or vocabulary, so a value can be plausible and wrong: a
  # name off the top of the page, a city beside a postcode, a job function
  # matched on a keyword.
  UNCERTAIN = %w[first_name last_name city country job_function years_of_experience].freeze

  EXTRACTED = "Extracted from CV".freeze
  CHECK = "Please check".freeze
  MISSING = "Missing".freeze

  def initialize(parsed_data)
    @parsed_data = parsed_data.presence || {}
  end

  # No CV, no labels: a candidate who typed everything has nothing to check.
  def any?
    parsed_data.any?
  end

  def label_for(field)
    field = field.to_s
    return unless any?
    return MISSING if parsed_data[field].blank?

    UNCERTAIN.include?(field) ? CHECK : EXTRACTED
  end

  private

  attr_reader :parsed_data
end
