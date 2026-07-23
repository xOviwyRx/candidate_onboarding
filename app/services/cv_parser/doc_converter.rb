module CvParser
  # DOC is a binary format with no usable Ruby reader, so it is converted to
  # DOCX and read through the path that already exists. LibreOffice is optional:
  # without it a DOC behaves exactly as it did before, failing cleanly so the
  # candidate fills the form in manually.
  class DocConverter
    BINARY = "soffice".freeze
    FILTER = "docx:MS Word 2007 XML".freeze

    def self.available?
      ENV["PATH"].to_s.split(File::PATH_SEPARATOR)
                 .any? { |directory| File.executable?(File.join(directory, BINARY)) }
    end

    # Yields the path of the converted DOCX. Both it and the working directory
    # are gone by the time this returns.
    def self.convert(path)
      raise TextExtractor::UnsupportedFormat, "LibreOffice is not installed" unless available?

      Dir.mktmpdir do |directory|
        # Separate arguments rather than a shell string: the file name comes
        # from the candidate, and interpolating it would be an injection hole.
        _out, error, status = Open3.capture3(
          BINARY, "--headless", "--convert-to", FILTER, "--outdir", directory, path
        )
        converted = Dir[File.join(directory, "*.docx")].first

        if !status.success? || converted.nil?
          raise TextExtractor::UnsupportedFormat, "DOC conversion failed: #{error.to_s.strip}"
        end

        yield converted
      end
    end
  end
end
