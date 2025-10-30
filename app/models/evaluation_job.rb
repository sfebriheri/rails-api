class EvaluationJob < ApplicationRecord
  STATUSES = %w[queued processing completed failed].freeze
  MAX_RETRY_COUNT = 3

  validates :job_id, presence: true, uniqueness: true
  validates :job_title, presence: true, length: { minimum: 2, maximum: 255 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :cv_match_rate, numericality: { in: 0.0..1.0 }, allow_nil: true
  validates :project_score, numericality: { in: 1.0..5.0 }, allow_nil: true
  validates :retry_count, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_RETRY_COUNT }
  validates :user_id, allow_nil: true  # Optional during migration
  validates :cv_document_id, presence: true
  validates :project_document_id, presence: true
  validate :validate_document_types
  validate :validate_state_transition

  belongs_to :cv_document, class_name: 'Document'
  belongs_to :project_document, class_name: 'Document'
  belongs_to :user, optional: true

  scope :by_status, ->(status) { where(status: status) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }

  before_validation :generate_job_id, on: :create
  before_update :validate_state_transition

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

  # State transition: queued -> processing
  def start_processing!
    raise "Invalid state transition" unless queued?

    update!(
      status: 'processing',
      started_at: Time.current,
      processing_steps: { started: Time.current.iso8601 },
      error_message: nil
    )
  end

  # State transition: processing -> completed
  def complete!(results)
    raise "Invalid state transition" unless processing?
    raise "Invalid results format" unless results.is_a?(Hash)

    validate_results(results)

    update!(
      status: 'completed',
      completed_at: Time.current,
      cv_match_rate: results[:cv_match_rate],
      cv_feedback: results[:cv_feedback],
      project_score: results[:project_score],
      project_feedback: results[:project_feedback],
      overall_summary: results[:overall_summary],
      processing_steps: (processing_steps || {}).merge(completed: Time.current.iso8601),
      error_message: nil,
      retry_count: 0
    )
  end

  # State transition: processing -> failed
  def fail!(error_message)
    raise "Invalid state transition" unless processing?
    raise "Error message is required" if error_message.blank?

    update!(
      status: 'failed',
      error_message: error_message,
      completed_at: Time.current,
      processing_steps: (processing_steps || {}).merge(failed: Time.current.iso8601)
    )
  end

  def increment_retry!
    raise "Max retries exceeded" if retry_count >= MAX_RETRY_COUNT
    increment!(:retry_count)
  end

  def can_retry?
    failed? && retry_count < MAX_RETRY_COUNT
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

  def validate_document_types
    if cv_document && cv_document.document_type != 'cv'
      errors.add(:cv_document, 'must be a CV document')
    end

    if project_document && project_document.document_type != 'project_report'
      errors.add(:project_document, 'must be a project report document')
    end
  end

  def validate_state_transition
    return if new_record?

    old_status = status_was
    new_status = status

    # Only allow specific transitions
    valid_transitions = {
      'queued' => ['processing'],
      'processing' => ['completed', 'failed'],
      'completed' => [],
      'failed' => []
    }

    unless valid_transitions[old_status]&.include?(new_status)
      errors.add(:status, "cannot transition from #{old_status} to #{new_status}")
    end
  end

  def validate_results(results)
    raise "cv_match_rate is required" if results[:cv_match_rate].blank?
    raise "cv_feedback is required" if results[:cv_feedback].blank?
    raise "project_score is required" if results[:project_score].blank?
    raise "project_feedback is required" if results[:project_feedback].blank?
    raise "overall_summary is required" if results[:overall_summary].blank?

    raise "Invalid cv_match_rate" unless (0.0..1.0).include?(results[:cv_match_rate])
    raise "Invalid project_score" unless (1.0..5.0).include?(results[:project_score])
  end
end
