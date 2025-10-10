class Document < ApplicationRecord
  DOCUMENT_TYPES = %w[cv project_report job_description case_study scoring_rubric].freeze
  
  validates :filename, presence: true
  validates :content_type, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0 }
  validates :file_path, presence: true
  validates :document_type, presence: true, inclusion: { in: DOCUMENT_TYPES }
  validates :checksum, presence: true, uniqueness: true

  has_many :vector_embeddings, dependent: :destroy
  has_many :cv_evaluations, class_name: 'EvaluationJob', foreign_key: 'cv_document_id'
  has_many :project_evaluations, class_name: 'EvaluationJob', foreign_key: 'project_document_id'

  scope :by_type, ->(type) { where(document_type: type) }
  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }

  before_validation :generate_checksum, if: :file_path_changed?

  def pdf?
    content_type == 'application/pdf'
  end

  def extract_text!
    return unless pdf? && File.exist?(file_path)
    
    begin
      reader = PDF::Reader.new(file_path)
      text = reader.pages.map(&:text).join("\n")
      
      update!(
        extracted_text: text,
        processed: true,
        processed_at: Time.current
      )
      
      # Queue embedding generation
      GenerateEmbeddingsJob.perform_async(id)
      
      text
    rescue => e
      Rails.logger.error "Failed to extract text from #{filename}: #{e.message}"
      raise
    end
  end

  def file_exists?
    File.exist?(file_path)
  end

  private

  def generate_checksum
    return unless File.exist?(file_path)
    self.checksum = Digest::SHA256.file(file_path).hexdigest
  end
end