module CvParser
  # Turns an uploaded CV into plain text. Everything downstream works on the
  # string this returns, so no other part of the parser knows about file formats.
  class TextExtractor
    UnsupportedFormat = Class.new(StandardError)

    # Named with the _CONTENT_TYPE suffix so PDF does not shadow pdf-reader's
    # own PDF module, which would break PDF::Reader below.
    PDF_CONTENT_TYPE = "application/pdf"
    DOCX_CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    # A real Word 97 file is sniffed as the generic OLE2 container type, not as
    # application/msword, so both have to route to the DOC branch.
    DOC_CONTENT_TYPES = %w[application/msword application/x-ole-storage].freeze

    def initialize(candidate_document)
      @candidate_document = candidate_document
    end

    def call
      case candidate_document.content_type
      when PDF_CONTENT_TYPE then extract_pdf
      when DOCX_CONTENT_TYPE then extract_docx
      when *DOC_CONTENT_TYPES then extract_doc
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
      download { |path| docx_text(path) }
    end

    # Converted first, then read as a DOCX, so there is one text-extraction path
    # rather than two.
    def extract_doc
      download { |path| DocConverter.convert(path) { |docx| docx_text(docx) } }
    end

    def docx_text(path)
      Zip::File.open(path) do |zip|
        entry = zip.find_entry("word/document.xml")
        raise UnsupportedFormat, "DOCX has no document body" if entry.nil?

        xml = Nokogiri::XML(entry.get_input_stream.read)
        xml.remove_namespaces!
        xml.css("p").map(&:text).join("\n")
      end
    end

    # Both readers need a real file on disk, which Active Storage only gives us
    # inside this block — the tempfile is deleted as soon as it returns.
    def download(&block)
      candidate_document.file.blob.open { |file| block.call(file.path) }
    end
  end
end
