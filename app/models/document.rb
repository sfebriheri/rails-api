class Document < ApplicationRecord
  DOCUMENT_TYPES = %w[cv project_report job_description case_study scoring_rubric].freeze

  validates :filename, presence: true, length: { maximum: 255 }
  validates :content_type, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10.megabytes }
  validates :file_path, presence: true
  validates :document_type, presence: true, inclusion: { in: DOCUMENT_TYPES }
  validates :checksum, presence: true, uniqueness: true
  validates :user_id, allow_nil: true  # Optional during migration

  has_many :vector_embeddings, dependent: :destroy
  has_many :cv_evaluations, class_name: 'EvaluationJob', foreign_key: 'cv_document_id'
  has_many :project_evaluations, class_name: 'EvaluationJob', foreign_key: 'project_document_id'
  belongs_to :user, optional: true

  scope :by_type, ->(type) { where(document_type: type) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }

  before_validation :generate_checksum, if: :file_path_changed?
  before_destroy :cleanup_file

  def pdf?
    content_type == 'application/pdf'
  end

  def extract_text!
    return unless pdf? && File.exist?(file_path)

    begin
      # Set timeout for PDF extraction to prevent hanging
      timeout = ENV.fetch('PDF_EXTRACT_TIMEOUT', 30).to_i
      text = nil

      Timeout.timeout(timeout) do
        File.open(file_path, 'rb') do |f|
          reader = PDF::Reader.new(f)

          # Limit pages to prevent memory exhaustion
          max_pages = 500
          pages = reader.pages.take(max_pages)

          text_parts = pages.map(&:text).compact
          text = text_parts.join("\n")
        end
      end

      # Validate extracted text size
      if text.nil? || text.strip.empty?
        update!(
          extracted_text: nil,
          processed: true,
          processed_at: Time.current,
          processing_error: 'No text content found'
        )
        return
      end

      if text.size > 10.megabytes
        update!(
          processed: true,
          processed_at: Time.current,
          processing_error: 'Extracted text too large'
        )
        return
      end

      update!(
        extracted_text: text,
        processed: true,
        processed_at: Time.current,
        processing_error: nil
      )

      # Queue embedding generation only if text extraction succeeded
      GenerateEmbeddingsJob.perform_later(id)

      text
    rescue Timeout::Error
      update!(processed: true, processing_error: 'Text extraction timeout')
      Rails.logger.error "Text extraction timeout for document #{id}"
      raise
    rescue => e
      update!(processed: true, processing_error: "Extraction error: #{e.message}")
      Rails.logger.error "Failed to extract text from #{filename}: #{e.class} - #{e.message}"
      raise
    end
  end

  def file_exists?
    File.exist?(file_path)
  end

  # Cleanup file when document is deleted
  def cleanup_file
    FileService.safe_delete_file(file_path) if file_path.present?
  end

  private

  def generate_checksum
    return unless File.exist?(file_path)
    self.checksum = Digest::SHA256.file(file_path).hexdigest
  end
end
