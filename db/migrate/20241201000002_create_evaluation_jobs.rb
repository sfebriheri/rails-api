class CreateEvaluationJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluation_jobs do |t|
      t.string :job_id, null: false, index: { unique: true }
      t.string :job_title, null: false
      t.references :cv_document, null: false, foreign_key: { to_table: :documents }
      t.references :project_document, null: false, foreign_key: { to_table: :documents }
      t.string :status, null: false, default: 'queued' # 'queued', 'processing', 'completed', 'failed'
      
      # Evaluation results
      t.decimal :cv_match_rate, precision: 3, scale: 2
      t.text :cv_feedback
      t.decimal :project_score, precision: 3, scale: 1
      t.text :project_feedback
      t.text :overall_summary
      
      # Processing metadata
      t.json :processing_steps, default: {}
      t.text :error_message
      t.integer :retry_count, default: 0
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :evaluation_jobs, :status
    add_index :evaluation_jobs, :job_title
    add_index :evaluation_jobs, :created_at
  end
end