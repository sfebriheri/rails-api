# AuditLogger - Tracks all significant application events for security and compliance
class AuditLogger
  ACTIONS = {
    # Document actions
    document_uploaded: 'Document uploaded',
    document_deleted: 'Document deleted',
    document_downloaded: 'Document downloaded',
    document_processed: 'Document text extracted',

    # Evaluation actions
    evaluation_started: 'Evaluation job created',
    evaluation_completed: 'Evaluation completed',
    evaluation_failed: 'Evaluation failed',

    # Authentication actions
    user_login: 'User login',
    user_logout: 'User logout',
    token_generated: 'Authentication token generated',
    token_invalid: 'Invalid token attempted',

    # Access control
    access_denied: 'Access denied',
    unauthorized_access_attempt: 'Unauthorized access attempt',

    # Data access
    results_viewed: 'Evaluation results viewed',
    document_viewed: 'Document metadata viewed'
  }.freeze

  def self.log(action, user_id, resource_type = nil, resource_id = nil, details = {})
    raise "Invalid action: #{action}" unless ACTIONS.key?(action.to_sym)

    AuditLog.create!(
      action: action,
      user_id: user_id,
      resource_type: resource_type,
      resource_id: resource_id,
      ip_address: details[:ip_address],
      user_agent: details[:user_agent],
      details: details.except(:ip_address, :user_agent),
      timestamp: Time.current
    )
  rescue => e
    Rails.logger.error "Audit logging failed: #{e.class} - #{e.message}"
    # Don't raise - audit logging shouldn't break application functionality
  end

  def self.log_document_upload(user_id, document_id, filename, file_size, ip_address, user_agent)
    log(:document_uploaded, user_id, 'Document', document_id, {
      filename: filename,
      file_size: file_size,
      ip_address: ip_address,
      user_agent: user_agent
    })
  end

  def self.log_document_deletion(user_id, document_id, filename, ip_address, user_agent)
    log(:document_deleted, user_id, 'Document', document_id, {
      filename: filename,
      ip_address: ip_address,
      user_agent: user_agent
    })
  end

  def self.log_evaluation_start(user_id, evaluation_job_id, job_title, ip_address, user_agent)
    log(:evaluation_started, user_id, 'EvaluationJob', evaluation_job_id, {
      job_title: job_title,
      ip_address: ip_address,
      user_agent: user_agent
    })
  end

  def self.log_evaluation_completion(user_id, evaluation_job_id, cv_match_rate, project_score, ip_address, user_agent)
    log(:evaluation_completed, user_id, 'EvaluationJob', evaluation_job_id, {
      cv_match_rate: cv_match_rate,
      project_score: project_score,
      ip_address: ip_address,
      user_agent: user_agent
    })
  end

  def self.log_evaluation_failure(user_id, evaluation_job_id, error_message, ip_address, user_agent)
    log(:evaluation_failed, user_id, 'EvaluationJob', evaluation_job_id, {
      error_message: error_message,
      ip_address: ip_address,
      user_agent: user_agent
    })
  end

  def self.log_unauthorized_access(user_id, resource_type, resource_id, reason, ip_address, user_agent)
    log(:unauthorized_access_attempt, user_id, resource_type, resource_id, {
      reason: reason,
      ip_address: ip_address,
      user_agent: user_agent
    })
  end

  def self.log_results_viewed(user_id, evaluation_job_id, ip_address, user_agent)
    log(:results_viewed, user_id, 'EvaluationJob', evaluation_job_id, {
      ip_address: ip_address,
      user_agent: user_agent
    })
  end

  def self.log_authentication_failure(ip_address, user_agent, reason)
    log(:token_invalid, nil, nil, nil, {
      reason: reason,
      ip_address: ip_address,
      user_agent: user_agent
    })
  end
end
