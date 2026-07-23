module CvParser
  # Fields a regular expression can find reliably, whatever the CV's layout.
  # Anything that needs to understand structure — education, work history —
  # belongs elsewhere; this only recognises shapes.
  class Patterns
    EMAIL = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i
    PHONE = /(?:\+|00)\d[\d\s\-()]{6,18}\d|\b0\d[\d\s\-()]{6,14}\d/
    BIG_NUMBER = /BIG[\s\-]*\w*[\s:.\-]*(\d{11})/i
    # The window between the number and the word "experience" is measured in
    # characters, not words, because real phrasing varies: "4+ years of backend
    # development experience". Excluding . and \n stops it spanning sentences.
    YEARS_OF_EXPERIENCE =
      /(\d{1,2}(?:[.,]5)?)\s*\+?\s*(?:jaar|jaren|years?)\b[^.\n]{0,40}?(?:ervaring|experience)/i

    PLAUSIBLE_PHONE_DIGITS = (9..15)

    def initialize(text)
      @text = text.to_s
    end

    # Keys the CV does not contain are dropped rather than set to nil, so the
    # review form can tell "not found" from "found and empty".
    def call
      {
        email: email,
        phone_number: phone_number,
        big_number: big_number,
        years_of_experience: years_of_experience
      }.compact
    end

    private

    attr_reader :text

    def email
      text[EMAIL]&.downcase
    end

    # Requiring a + or a leading 0 keeps years and postcodes out; the digit count
    # then rejects dates like 01-02-1990 that still match the shape.
    def phone_number
      text_without_big_number
        .scan(PHONE)
        .find { |match| PLAUSIBLE_PHONE_DIGITS.cover?(match.count("0-9")) }
        &.squish
    end

    def big_number
      text[BIG_NUMBER, 1]
    end

    def years_of_experience
      text[YEARS_OF_EXPERIENCE, 1]&.tr(",", ".")&.to_f
    end

    # A BIG number is eleven digits and can read exactly like a phone number, so
    # it comes out of the text before we go looking for one.
    def text_without_big_number
      big_number ? text.sub(big_number, "") : text
    end
  end
end
