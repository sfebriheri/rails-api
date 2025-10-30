require 'rails_helper'

RSpec.describe VectorEmbedding, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:content_chunk) }
    it { is_expected.to validate_presence_of(:embedding_vector) }
    it { is_expected.to validate_presence_of(:chunk_index) }
    it { is_expected.to validate_presence_of(:document_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:document) }
  end

  describe '.search_similar' do
    let(:document) { create(:document, :processed) }
    let(:query_embedding) { [0.1, 0.2, 0.3, 0.4, 0.5] }

    before do
      create(:vector_embedding, document: document, embedding_vector: [0.1, 0.2, 0.3, 0.4, 0.5], chunk_index: 0)
      create(:vector_embedding, document: document, embedding_vector: [0.9, 0.8, 0.7, 0.6, 0.5], chunk_index: 1)
    end

    it 'returns similar embeddings' do
      results = VectorEmbedding.search_similar(query_embedding)
      expect(results).to be_a(Array)
      expect(results.length).to be > 0
    end

    it 'raises error for blank query embedding' do
      expect {
        VectorEmbedding.search_similar(nil)
      }.to raise_error(/Query embedding cannot be empty/)
    end

    it 'raises error for non-array query embedding' do
      expect {
        VectorEmbedding.search_similar('not-an-array')
      }.to raise_error(/Query embedding must be numeric array/)
    end

    it 'filters by document types' do
      results = VectorEmbedding.search_similar(query_embedding, document_types: ['cv'])
      expect(results).to be_a(Array)
    end

    it 'respects limit parameter' do
      results = VectorEmbedding.search_similar(query_embedding, limit: 1)
      expect(results.length).to be <= 1
    end

    it 'raises error for invalid document type' do
      expect {
        VectorEmbedding.search_similar(query_embedding, document_types: ['invalid_type'])
      }.to raise_error(/Invalid document type/)
    end
  end

  describe '.search_by_document_type' do
    let(:document) { create(:document, :processed, document_type: 'cv') }
    let(:query_embedding) { [0.1, 0.2, 0.3, 0.4, 0.5] }

    before do
      create(:vector_embedding, document: document, embedding_vector: [0.1, 0.2, 0.3, 0.4, 0.5], chunk_index: 0)
    end

    it 'searches by specific document type' do
      results = VectorEmbedding.search_by_document_type(query_embedding, 'cv')
      expect(results).to be_a(Array)
    end

    it 'raises error for invalid document type' do
      expect {
        VectorEmbedding.search_by_document_type(query_embedding, 'invalid')
      }.to raise_error(/Invalid document type/)
    end
  end

  describe '.retrieve_context' do
    let(:document) { create(:document, :processed) }
    let(:query_embedding) { [0.1, 0.2, 0.3, 0.4, 0.5] }

    context 'with results' do
      before do
        create(:vector_embedding,
          document: document,
          content_chunk: 'Sample context text',
          embedding_vector: [0.1, 0.2, 0.3, 0.4, 0.5],
          chunk_index: 0
        )
      end

      it 'returns concatenated context' do
        context = VectorEmbedding.retrieve_context(query_embedding, [document.document_type])
        expect(context).to be_a(String)
        expect(context).to include('Sample context text')
      end
    end

    context 'without results' do
      it 'returns empty string when no results' do
        context = VectorEmbedding.retrieve_context(query_embedding, ['cv'])
        expect(context).to eq('')
      end
    end
  end

  describe 'cosine_similarity calculation' do
    it 'calculates similarity between vectors' do
      vec_a = [1, 0, 0]
      vec_b = [1, 0, 0]
      # Same vectors should have similarity of 1.0
      similarity = VectorEmbedding.send(:cosine_similarity, vec_a, vec_b)
      expect(similarity).to eq(1.0)
    end

    it 'returns 0 for orthogonal vectors' do
      vec_a = [1, 0, 0]
      vec_b = [0, 1, 0]
      similarity = VectorEmbedding.send(:cosine_similarity, vec_a, vec_b)
      expect(similarity).to eq(0.0)
    end

    it 'handles zero magnitude vectors' do
      vec_a = [0, 0, 0]
      vec_b = [1, 1, 1]
      similarity = VectorEmbedding.send(:cosine_similarity, vec_a, vec_b)
      expect(similarity).to eq(0.0)
    end
  end
end
