class EvaluationJob < ApplicationRecord
  STATUSES = %w[queued processing completed failed].freeze
  
  validates :job_id, presence: true, uniqueness: true
  validates :job_title, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :cv_match_rate, numericality: { in: 0.0..1.0 }, allow_nil: true
  validates :project_score, numericality: { in: 1.0..5.0 }, allow_nil: true

  belongs_to :cv_document, class_name: 'Document'
  belongs_to :project_document, class_name: 'Document'

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }

  before_validation :generate_job_id, on: :create

  def queued?
    status == 'queued'
  end

  def processing?
    status == 'processing'
  end

  def completed?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end

  def start_processing!
    update!(
      status: 'processing',
      started_at: Time.current,
      processing_steps: { started: Time.current.iso8601 }
    )
  end

  def complete!(results)
    update!(
      status: 'completed',
      completed_at: Time.current,
      cv_match_rate: results[:cv_match_rate],
      cv_feedback: results[:cv_feedback],
      project_score: results[:project_score],
      project_feedback: results[:project_feedback],
      overall_summary: results[:overall_summary],
      processing_steps: processing_steps.merge(completed: Time.current.iso8601)
    )
  end

  def fail!(error_message)
    update!(
      status: 'failed',
      error_message: error_message,
      completed_at: Time.current,
      processing_steps: processing_steps.merge(failed: Time.current.iso8601)
    )
  end

  def increment_retry!
    increment!(:retry_count)
  end

  def can_retry?
    retry_count < 3 && failed?
  end

  def result
    return nil unless completed?
    
    {
      cv_match_rate: cv_match_rate,
      cv_feedback: cv_feedback,
      project_score: project_score,
      project_feedback: project_feedback,
      overall_summary: overall_summary
    }
  end

  private

  def generate_job_id
    self.job_id ||= SecureRandom.uuid
  end
end