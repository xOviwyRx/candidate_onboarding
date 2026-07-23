module CvParser
  # Turns an uploaded CV into plain text. Everything downstream works on the
  # string this returns, so no other part of the parser knows about file formats.
  class TextExtractor
    UnsupportedFormat = Class.new(StandardError)

    # Named with the _CONTENT_TYPE suffix so PDF does not shadow pdf-reader's
    # own PDF module, which would break PDF::Reader below.
    PDF_CONTENT_TYPE = "application/pdf"
    DOCX_CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

    def initialize(candidate_document)
      @candidate_document = candidate_document
    end

    def call
      case candidate_document.content_type
      when PDF_CONTENT_TYPE then extract_pdf
      when DOCX_CONTENT_TYPE then extract_docx
      else
        raise UnsupportedFormat, "Cannot extract text from #{candidate_document.content_type}"
      end
    end

    private

    attr_reader :candidate_document

    def extract_pdf
      download { |path| PDF::Reader.new(path).pages.map(&:text).join("\n") }
    end

    # A .docx is a zip archive whose word/document.xml holds the body. Reading
    # paragraphs individually keeps the line breaks that section detection needs;
    # calling .text on the whole document would run them together.
    def extract_docx
      download do |path|
        Zip::File.open(path) do |zip|
          entry = zip.find_entry("word/document.xml")
          raise UnsupportedFormat, "DOCX has no document body" if entry.nil?

          xml = Nokogiri::XML(entry.get_input_stream.read)
          xml.remove_namespaces!
          xml.css("p").map(&:text).join("\n")
        end
      end
    end

    # Both readers need a real file on disk, which Active Storage only gives us
    # inside this block — the tempfile is deleted as soon as it returns.
    def download(&block)
      candidate_document.file.blob.open { |file| block.call(file.path) }
    end
  end
end
