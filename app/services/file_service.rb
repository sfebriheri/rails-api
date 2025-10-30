# FileService - Secure file handling and validation
class FileService
  MAX_FILE_SIZE = ENV.fetch('MAX_FILE_SIZE', 10.megabytes).to_i.freeze
  ALLOWED_EXTENSIONS = %w[pdf].freeze
  UPLOAD_DIR = Rails.root.join('storage', 'uploads').freeze

  class InvalidFileError < StandardError; end
  class FileTooLargeError < StandardError; end
  class CorruptedFileError < StandardError; end

  def self.validate_and_save_pdf(uploaded_file, user_id)
    raise InvalidFileError, 'File is required' if uploaded_file.blank?
    raise InvalidFileError, 'User ID is required' if user_id.blank?

    # Validate file size
    validate_file_size(uploaded_file)

    # Validate file type by extension and magic bytes
    validate_file_type(uploaded_file)

    # Validate PDF integrity
    validate_pdf_integrity(uploaded_file)

    # Save file securely
    save_file_safely(uploaded_file, user_id)
  end

  private

  def self.validate_file_size(file)
    if file.size > MAX_FILE_SIZE
      max_size_mb = MAX_FILE_SIZE / (1024 * 1024)
      raise FileTooLargeError, "File exceeds maximum size of #{max_size_mb}MB (#{MAX_FILE_SIZE} bytes)"
    end

    if file.size.zero?
      raise InvalidFileError, 'File is empty'
    end
  end

  def self.validate_file_type(file)
    # Check MIME type
    unless file.content_type == 'application/pdf'
      raise InvalidFileError, "Invalid file type. Expected application/pdf, got #{file.content_type}"
    end

    # Check file extension
    extension = File.extname(file.original_filename).downcase.delete('.')
    unless ALLOWED_EXTENSIONS.include?(extension)
      raise InvalidFileError, "Invalid file extension. Only #{ALLOWED_EXTENSIONS.join(', ')} allowed"
    end

    # Verify magic bytes for PDF
    unless is_valid_pdf_magic?(file)
      raise InvalidFileError, 'File does not appear to be a valid PDF'
    end
  end

  def self.is_valid_pdf_magic?(file)
    # PDF files start with %PDF
    magic_bytes = file.read(4)
    file.rewind
    magic_bytes.start_with?('%PDF')
  rescue
    false
  end

  def self.validate_pdf_integrity(file)
    # Attempt to read PDF to ensure it's not corrupted
    temp_path = Rails.root.join('tmp', "validate_#{SecureRandom.uuid}.pdf")

    begin
      # Write to temporary file
      File.open(temp_path, 'wb') do |f|
        f.write(file.read)
      end
      file.rewind

      # Try to open with PDF reader
      PDF::Reader.new(temp_path)
    rescue => e
      raise CorruptedFileError, "PDF validation failed: #{e.message}"
    ensure
      File.delete(temp_path) if File.exist?(temp_path)
    end
  end

  def self.save_file_safely(file, user_id)
    # Ensure upload directory exists
    FileUtils.mkdir_p(UPLOAD_DIR)

    # Generate secure filename (UUID only, ignore original filename)
    uuid = SecureRandom.uuid
    extension = File.extname(file.original_filename).downcase
    final_filename = "#{uuid}#{extension}"
    final_path = UPLOAD_DIR.join(final_filename)

    begin
      # Write file in chunks to avoid memory exhaustion
      File.open(final_path, 'wb') do |f|
        while chunk = file.read(1.megabyte)
          f.write(chunk)
        end
      end
      file.rewind

      # Set restrictive file permissions (owner read/write only)
      File.chmod(0600, final_path)

      # Calculate SHA256 checksum
      checksum = calculate_checksum(final_path)

      # Check for duplicate files
      existing = Document.find_by(checksum: checksum)
      if existing
        File.delete(final_path)
        raise InvalidFileError, 'Duplicate file detected. This file has already been uploaded.'
      end

      # Return document data for creation
      {
        filename: file.original_filename,
        content_type: file.content_type,
        file_size: file.size,
        file_path: final_path.to_s,
        checksum: checksum,
        user_id: user_id
      }
    rescue => e
      # Clean up file if save failed
      File.delete(final_path) if File.exist?(final_path)
      raise
    end
  end

  def self.calculate_checksum(file_path)
    Digest::SHA256.file(file_path).hexdigest
  end

  def self.safe_delete_file(file_path)
    return unless file_path.present? && File.exist?(file_path)

    # Ensure file is within upload directory (prevent directory traversal)
    unless File.expand_path(file_path).start_with?(UPLOAD_DIR.to_s)
      Rails.logger.warn "Attempted to delete file outside upload directory: #{file_path}"
      return
    end

    File.delete(file_path)
  rescue => e
    Rails.logger.error "Failed to delete file #{file_path}: #{e.message}"
  end
end
