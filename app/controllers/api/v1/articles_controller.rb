module Api
  module V1
    class ArticlesController < Api::BaseController
      before_action :set_article, only: [:show, :update, :destroy]

      # GET /api/v1/articles
      def index
        @articles = Article.all
        render json: @articles
      end

      # GET /api/v1/articles/:id
      def show
        render json: @article
      end

      # POST /api/v1/articles
      def create
        @article = Article.new(article_params)

        if @article.save
          render json: @article, status: :created
        else
          render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/articles/:id
      def update
        if @article.update(article_params)
          render json: @article
        else
          render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/articles/:id
      def destroy
        @article.destroy
        head :no_content
      end

      private

      def set_article
        @article = Article.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      def article_params
        params.require(:article).permit(:title, :body, :published)
      end
    end
  end
end
