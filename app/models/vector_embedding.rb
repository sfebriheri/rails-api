class VectorEmbedding < ApplicationRecord
  validates :content_chunk, presence: true, length: { maximum: 10000 }
  validates :embedding_vector, presence: true
  validates :chunk_index, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :document_id, presence: true

  belongs_to :document

  scope :by_document, ->(document) { where(document: document) }
  scope :by_documents, ->(documents) { where(document_id: documents.pluck(:id)) }
  scope :ordered, -> { order(:chunk_index) }
  scope :by_document_types, ->(types) { joins(:document).where(documents: { document_type: types }) }

  # Search for similar embeddings using cosine similarity
  # Optimized to prevent N+1 queries
  def self.search_similar(query_embedding, limit: 5, document_types: nil)
    raise "Query embedding cannot be empty" if query_embedding.blank?
    raise "Query embedding must be numeric array" unless query_embedding.is_a?(Array)

    # Include document association upfront to prevent N+1 query
    embeddings_scope = includes(:document).all

    # Filter by document types if provided
    if document_types.present?
      Array(document_types).each do |type|
        raise "Invalid document type: #{type}" unless Document::DOCUMENT_TYPES.include?(type)
      end
      embeddings_scope = embeddings_scope.by_document_types(document_types)
    end

    # Calculate similarities
    similarities = embeddings_scope.map do |embedding|
      similarity = cosine_similarity(query_embedding, embedding.embedding_vector)
      { embedding: embedding, similarity: similarity }
    end

    # Sort and return top results
    sorted = similarities.sort_by { |item| -item[:similarity] }
    sorted.empty? ? [] : sorted.first(limit)
  end

  # Find similar embeddings for a specific document type
  def self.search_by_document_type(query_embedding, document_type, limit: 5)
    raise "Invalid document type" unless Document::DOCUMENT_TYPES.include?(document_type)

    search_similar(query_embedding, limit: limit, document_types: [document_type])
  end

  # Get embeddings for context retrieval with efficient loading
  def self.retrieve_context(query_embedding, document_types, limit: 10)
    results = search_similar(query_embedding, limit: limit, document_types: document_types)
    return "" if results.blank?
    results.map { |item| item[:embedding].content_chunk }.join("\n\n")
  end

  private

  def self.cosine_similarity(vec_a, vec_b)
    return 0.0 if vec_a.blank? || vec_b.blank? || vec_a.length != vec_b.length

    # Convert to float array if needed
    vec_a = vec_a.map(&:to_f)
    vec_b = vec_b.map(&:to_f)

    dot_product = vec_a.zip(vec_b).sum { |a, b| a * b }
    magnitude_a = Math.sqrt(vec_a.sum { |a| a * a })
    magnitude_b = Math.sqrt(vec_b.sum { |b| b * b })

    return 0.0 if magnitude_a == 0.0 || magnitude_b == 0.0

    (dot_product / (magnitude_a * magnitude_b)).round(4)
  end
end
