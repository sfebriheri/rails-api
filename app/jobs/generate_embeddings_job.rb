class GenerateEmbeddingsJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(document_id)
    document = Document.find(document_id)
    
    return unless document.processed? && document.extracted_text.present?
    
    Rails.logger.info "Starting embedding generation for document #{document.id}: #{document.filename}"
    
    # Split text into chunks
    chunks = split_text_into_chunks(document.extracted_text)
    
    chunks.each_with_index do |chunk, index|
      # Generate embedding using OpenAI or similar service
      embedding = generate_embedding(chunk)
      
      VectorEmbedding.create!(
        document: document,
        content_chunk: chunk,
        embedding_vector: embedding,
        chunk_index: index,
        metadata: {
          chunk_size: chunk.length,
          document_type: document.document_type
        }
      )
    end
    
    Rails.logger.info "Embedding generation completed for document #{document.id}. Generated #{chunks.size} embeddings."
  rescue => e
    Rails.logger.error "Embedding generation failed for document #{document_id}: #{e.message}"
    raise
  end

  private

  def split_text_into_chunks(text, chunk_size: 1000, overlap: 200)
    chunks = []
    start = 0
    
    while start < text.length
      end_pos = [start + chunk_size, text.length].min
      
      # Try to break at sentence boundary
      if end_pos < text.length
        last_period = text.rindex('.', end_pos)
        last_newline = text.rindex("\n", end_pos)
        break_point = [last_period, last_newline].compact.max
        
        end_pos = break_point + 1 if break_point && break_point > start + chunk_size / 2
      end
      
      chunk = text[start...end_pos].strip
      chunks << chunk if chunk.length > 50 # Skip very short chunks
      
      start = end_pos - overlap
      break if start >= text.length
    end
    
    chunks
  end

  def generate_embedding(text)
    # This would integrate with OpenAI's embedding API
    # For now, return a mock embedding vector
    # In production, you'd call: OpenAI.embeddings(input: text, model: "text-embedding-ada-002")
    
    # Mock embedding - replace with actual API call
    Array.new(1536) { rand(-1.0..1.0) }
  end
end