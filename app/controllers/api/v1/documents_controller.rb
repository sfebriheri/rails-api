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

        begin
          # Ensure user is authenticated
          raise "User not authenticated" unless @current_user&.id

          # Validate and save CV file
          cv_data = FileService.validate_and_save_pdf(cv_file, @current_user.id)
          cv_document = Document.create!(**cv_data, document_type: 'cv')

          # Validate and save project report file
          project_data = FileService.validate_and_save_pdf(project_file, @current_user.id)
          project_document = Document.create!(**project_data, document_type: 'project_report')

          # Queue text extraction jobs
          ExtractTextJob.perform_later(cv_document.id)
          ExtractTextJob.perform_later(project_document.id)

          render_success({
            cv: document_response(cv_document),
            project_report: document_response(project_document)
          }, status: :created)

        rescue FileService::InvalidFileError => e
          render_error(e.message, status: :bad_request)
        rescue FileService::FileTooLargeError => e
          render_error(e.message, status: :request_entity_too_large)
        rescue FileService::CorruptedFileError => e
          render_error(e.message, status: :unprocessable_entity)
        rescue => e
          Rails.logger.error "File upload failed: #{e.class} - #{e.message}"
          render_error('File upload failed', status: :internal_server_error)
        end
      end

      private

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
