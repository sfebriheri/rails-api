require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe 'scopes' do
    let!(:published_article) { create(:article, :published) }
    let!(:unpublished_article) { create(:article, :unpublished) }

    describe '.published' do
      it 'returns only published articles' do
        expect(Article.published).to include(published_article)
        expect(Article.published).not_to include(unpublished_article)
      end
    end

    describe '.unpublished' do
      it 'returns only unpublished articles' do
        expect(Article.unpublished).to include(unpublished_article)
        expect(Article.unpublished).not_to include(published_article)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid article' do
      article = build(:article)
      expect(article).to be_valid
    end
  end
end
