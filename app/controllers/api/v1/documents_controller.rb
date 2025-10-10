module Api
  module V1
    class DocumentsController < Api::BaseController
      # POST /api/v1/upload
      def upload
        cv_file = params[:cv]
        project_file = params[:project_report]

        if cv_file.blank? || project_file.blank?
          return render_error('Both CV and project report files are required', status: :bad_request)
        end

        unless valid_pdf?(cv_file) && valid_pdf?(project_file)
          return render_error('Only PDF files are allowed', status: :bad_request)
        end

        begin
          cv_document = save_document(cv_file, 'cv')
          project_document = save_document(project_file, 'project_report')

          # Queue text extraction jobs
          ExtractTextJob.perform_later(cv_document.id)
          ExtractTextJob.perform_later(project_document.id)

          render_success({
            cv: document_response(cv_document),
            project_report: document_response(project_document)
          }, status: :created)

        rescue => e
          Rails.logger.error "File upload failed: #{e.message}"
          render_error('File upload failed', status: :internal_server_error)
        end
      end

      private

      def valid_pdf?(file)
        file.present? && file.content_type == 'application/pdf'
      end

      def save_document(file, document_type)
        # Create uploads directory if it doesn't exist
        upload_dir = Rails.root.join('storage', 'uploads')
        FileUtils.mkdir_p(upload_dir)

        # Generate unique filename
        timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
        filename = "#{timestamp}_#{SecureRandom.hex(8)}_#{file.original_filename}"
        file_path = upload_dir.join(filename)

        # Save file to disk
        File.open(file_path, 'wb') do |f|
          f.write(file.read)
        end

        # Create document record
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
          created_at: document.created_at
        }
      end
    end
  end
end