require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:filename) }
    it { is_expected.to validate_presence_of(:content_type) }
    it { is_expected.to validate_presence_of(:file_size) }
    it { is_expected.to validate_presence_of(:file_path) }
    it { is_expected.to validate_presence_of(:document_type) }
    it { is_expected.to validate_presence_of(:checksum) }
    it { is_expected.to validate_uniqueness_of(:checksum) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:vector_embeddings).dependent(:destroy) }
    it { is_expected.to have_many(:cv_evaluations) }
    it { is_expected.to have_many(:project_evaluations) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'document types' do
    it 'accepts valid document types' do
      valid_types = %w[cv project_report job_description case_study scoring_rubric]
      valid_types.each do |type|
        doc = build(:document, document_type: type)
        expect(doc).to be_valid
      end
    end

    it 'rejects invalid document types' do
      doc = build(:document, document_type: 'invalid_type')
      expect(doc).not_to be_valid
    end
  end

  describe '#pdf?' do
    it 'returns true for PDF files' do
      doc = build(:document, content_type: 'application/pdf')
      expect(doc.pdf?).to be true
    end

    it 'returns false for non-PDF files' do
      doc = build(:document, content_type: 'application/txt')
      expect(doc.pdf?).to be false
    end
  end
end
