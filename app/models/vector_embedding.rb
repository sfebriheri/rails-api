class VectorEmbedding < ApplicationRecord
  validates :content_chunk, presence: true
  validates :embedding_vector, presence: true
  validates :chunk_index, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :document

  scope :by_document, ->(document) { where(document: document) }
  scope :ordered, -> { order(:chunk_index) }

  def self.search_similar(query_embedding, limit: 5, document_types: nil)
    # This would typically use a vector database like ChromaDB or pgvector
    # For now, we'll implement a basic cosine similarity search
    embeddings = all
    embeddings = embeddings.joins(:document).where(documents: { document_type: document_types }) if document_types
    
    similarities = embeddings.map do |embedding|
      similarity = cosine_similarity(query_embedding, embedding.embedding_vector)
      { embedding: embedding, similarity: similarity }
    end
    
    similarities.sort_by { |item| -item[:similarity] }.first(limit)
  end

  private

  def self.cosine_similarity(vec_a, vec_b)
    return 0.0 if vec_a.empty? || vec_b.empty? || vec_a.length != vec_b.length
    
    dot_product = vec_a.zip(vec_b).sum { |a, b| a * b }
    magnitude_a = Math.sqrt(vec_a.sum { |a| a * a })
    magnitude_b = Math.sqrt(vec_b.sum { |b| b * b })
    
    return 0.0 if magnitude_a == 0.0 || magnitude_b == 0.0
    
    dot_product / (magnitude_a * magnitude_b)
  end
end