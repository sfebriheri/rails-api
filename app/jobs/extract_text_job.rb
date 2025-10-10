class ExtractTextJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(document_id)
    document = Document.find(document_id)
    
    Rails.logger.info "Starting text extraction for document #{document.id}: #{document.filename}"
    
    document.extract_text!
    
    Rails.logger.info "Text extraction completed for document #{document.id}"
  rescue => e
    Rails.logger.error "Text extraction failed for document #{document_id}: #{e.message}"
    raise
  end
end