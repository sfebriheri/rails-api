class AuditLog < ApplicationRecord
  validates :action, presence: true
  validates :resource_type, presence: true, allow_nil: true
  validates :timestamp, presence: true

  belongs_to :user, optional: true

  scope :recent, -> { order(timestamp: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_resource, ->(type, id) { where(resource_type: type, resource_id: id) }
  scope :since, ->(time) { where('timestamp >= ?', time) }
  scope :security_events, -> { where(action: %i[access_denied unauthorized_access_attempt token_invalid]) }

  # Don't allow updates or deletes on audit logs
  before_update { raise "Audit logs cannot be modified" }
  before_destroy { raise "Audit logs cannot be deleted" }

  def self.retention_period
    ENV.fetch('AUDIT_LOG_RETENTION_DAYS', 90).to_i.days
  end

  def self.cleanup_old_logs
    cutoff_date = Time.current - retention_period
    deleted_count = where('timestamp < ?', cutoff_date).delete_all
    Rails.logger.info "Deleted #{deleted_count} old audit logs"
    deleted_count
  end

  # Check if user had access to resource at the time of access
  def self.user_had_access?(user_id, resource_type, resource_id, action_time)
    by_user(user_id).by_resource(resource_type, resource_id).since(action_time - 1.second).exists?
  end
end
