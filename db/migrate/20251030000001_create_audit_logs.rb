class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.string :action, null: false
      t.bigint :user_id, null: true
      t.string :resource_type
      t.bigint :resource_id
      t.inet :ip_address
      t.string :user_agent
      t.jsonb :details, default: {}
      t.timestamp :timestamp, null: false

      t.timestamps
    end

    # Indexes for common queries
    add_index :audit_logs, :action
    add_index :audit_logs, :user_id
    add_index :audit_logs, %i[resource_type resource_id]
    add_index :audit_logs, :timestamp
    add_index :audit_logs, :ip_address
    add_index :audit_logs, %i[user_id timestamp]
    add_index :audit_logs, %i[action timestamp]

    # Foreign key to users table
    add_foreign_key :audit_logs, :users, column: :user_id, on_delete: :nullify
  end
end
