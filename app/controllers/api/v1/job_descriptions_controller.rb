module Api
  module V1
    class JobDescriptionsController < Api::BaseController
      before_action :set_document, only: [:show, :destroy]

      # GET /api/v1/job_descriptions
      def index
        documents = Document.by_type('job_description').order(created_at: :desc)
        render_success(documents.map { |doc| document_response(doc) })
      end

      # GET /api/v1/job_descriptions/:id
      def show
        render_success(document_response(@document))
      end

      # POST /api/v1/job_descriptions
      def create
        file = params[:file]

        if file.blank?
          return render_error('File is required', status: :bad_request)
        end

        unless valid_pdf?(file)
          return render_error('Only PDF files are allowed', status: :bad_request)
        end

        begin
          document = save_document(file, 'job_description')
          ExtractTextJob.perform_later(document.id)

          render_success(document_response(document), status: :created)
        rescue => e
          Rails.logger.error "Job description upload failed: #{e.message}"
          render_error('File upload failed', status: :internal_server_error)
        end
      end

      # DELETE /api/v1/job_descriptions/:id
      def destroy
        @document.destroy
        render_success({ message: 'Job description deleted successfully' })
      end

      private

      def set_document
        @document = Document.by_type('job_description').find(params[:id])
      end

      def valid_pdf?(file)
        file.present? && file.content_type == 'application/pdf'
      end

      def save_document(file, document_type)
        upload_dir = Rails.root.join('storage', 'uploads', 'reference_docs')
        FileUtils.mkdir_p(upload_dir)

        timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
        filename = "#{timestamp}_#{SecureRandom.hex(8)}_#{file.original_filename}"
        file_path = upload_dir.join(filename)

        File.open(file_path, 'wb') do |f|
          f.write(file.read)
        end

        Document.create!(
          filename: file.original_filename,
          content_type: file.content_type,
          file_size: file.size,
          file_path: file_path.to_s,
          document_type: document_type
        )
      end

      def document_response(document)
        {
          id: document.id,
          filename: document.filename,
          document_type: document.document_type,
          file_size: document.file_size,
          processed: document.processed,
          created_at: document.created_at,
          updated_at: document.updated_at
        }
      end
    end
  end
end