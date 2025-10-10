class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :filename, null: false
      t.string :content_type, null: false
      t.integer :file_size, null: false
      t.text :file_path, null: false
      t.string :document_type, null: false # 'cv', 'project_report', 'job_description', 'case_study', 'scoring_rubric'
      t.text :extracted_text
      t.json :metadata, default: {}
      t.string :checksum
      t.boolean :processed, default: false
      t.datetime :processed_at

      t.timestamps
    end

    add_index :documents, :document_type
    add_index :documents, :checksum
    add_index :documents, :processed
  end
end