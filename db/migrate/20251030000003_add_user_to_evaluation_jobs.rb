class AddUserToEvaluationJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluation_jobs, :user_id, :bigint, null: true unless column_exists?(:evaluation_jobs, :user_id)
    add_index :evaluation_jobs, :user_id unless index_exists?(:evaluation_jobs, :user_id)

    # Add foreign key if not already present
    begin
      add_foreign_key :evaluation_jobs, :users, on_delete: :cascade
    rescue ActiveRecord::StatementInvalid
      # Foreign key already exists
    end
  end
end
