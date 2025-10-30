class AddUserToDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :documents, :user_id, :bigint, null: true unless column_exists?(:documents, :user_id)
    add_index :documents, :user_id unless index_exists?(:documents, :user_id)

    # Add foreign key if not already present
    begin
      add_foreign_key :documents, :users, on_delete: :cascade
    rescue ActiveRecord::StatementInvalid
      # Foreign key already exists
    end

    # Add processing_error column for error tracking
    add_column :documents, :processing_error, :text unless column_exists?(:documents, :processing_error)
  end
end
