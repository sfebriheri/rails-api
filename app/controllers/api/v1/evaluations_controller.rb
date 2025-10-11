module Api
  module V1
    class EvaluationsController < Api::BaseController
      # POST /api/v1/evaluate
      def create
        job_title = params.require(:job_title)
        cv_document_id = params.require(:cv_document_id)
        project_document_id = params.require(:project_document_id)

        cv_document = Document.find(cv_document_id)
        project_document = Document.find(project_document_id)

        # Validate document types
        unless cv_document.document_type == 'cv'
          return render_error('Invalid CV document', status: :bad_request)
        end

        unless project_document.document_type == 'project_report'
          return render_error('Invalid project report document', status: :bad_request)
        end

        # Ensure documents are processed
        unless cv_document.processed? && project_document.processed?
          return render_error('Documents are still being processed. Please wait and try again.', status: :unprocessable_entity)
        end

        # Create evaluation job
        evaluation_job = EvaluationJob.create!(
          job_title: job_title,
          cv_document: cv_document,
          project_document: project_document
        )

        # Queue the evaluation job
        EvaluationWorkerJob.perform_later(evaluation_job.id)

        render_success({
          id: evaluation_job.job_id,
          status: evaluation_job.status
        }, status: :created)

      rescue ActiveRecord::RecordNotFound => e
        render_not_found('Document not found')
      end

      # GET /api/v1/result/:id
      def show
        job_id = params[:id]
        evaluation_job = EvaluationJob.find_by!(job_id: job_id)

        response_data = {
          id: evaluation_job.job_id,
          status: evaluation_job.status
        }

        if evaluation_job.completed?
          response_data[:result] = evaluation_job.result
        elsif evaluation_job.failed?
          response_data[:error] = evaluation_job.error_message
        end

        render_success(response_data)

      rescue ActiveRecord::RecordNotFound
        render_not_found('Evaluation job not found')
      end
    end
  end
end