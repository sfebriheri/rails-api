# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_10_30_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "user_id"
    t.string "resource_type"
    t.bigint "resource_id"
    t.inet "ip_address"
    t.string "user_agent"
    t.jsonb "details", default: {}
    t.datetime "timestamp", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action", "timestamp"], name: "index_audit_logs_on_action_and_timestamp"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["ip_address"], name: "index_audit_logs_on_ip_address"
    t.index ["resource_type", "resource_id"], name: "index_audit_logs_on_resource_type_and_resource_id"
    t.index ["timestamp"], name: "index_audit_logs_on_timestamp"
    t.index ["user_id", "timestamp"], name: "index_audit_logs_on_user_id_and_timestamp"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "filename", null: false
    t.string "content_type", null: false
    t.integer "file_size", null: false
    t.text "file_path", null: false
    t.string "document_type", null: false
    t.text "extracted_text"
    t.json "metadata", default: {}
    t.string "checksum"
    t.boolean "processed", default: false
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.text "processing_error"
    t.index ["checksum"], name: "index_documents_on_checksum"
    t.index ["document_type"], name: "index_documents_on_document_type"
    t.index ["processed"], name: "index_documents_on_processed"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "evaluation_jobs", force: :cascade do |t|
    t.string "job_id", null: false
    t.string "job_title", null: false
    t.bigint "cv_document_id", null: false
    t.bigint "project_document_id", null: false
    t.string "status", default: "queued", null: false
    t.decimal "cv_match_rate", precision: 3, scale: 2
    t.text "cv_feedback"
    t.decimal "project_score", precision: 3, scale: 1
    t.text "project_feedback"
    t.text "overall_summary"
    t.json "processing_steps", default: {}
    t.text "error_message"
    t.integer "retry_count", default: 0
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_evaluation_jobs_on_created_at"
    t.index ["cv_document_id"], name: "index_evaluation_jobs_on_cv_document_id"
    t.index ["job_id"], name: "index_evaluation_jobs_on_job_id", unique: true
    t.index ["job_title"], name: "index_evaluation_jobs_on_job_title"
    t.index ["project_document_id"], name: "index_evaluation_jobs_on_project_document_id"
    t.index ["status"], name: "index_evaluation_jobs_on_status"
    t.index ["user_id"], name: "index_evaluation_jobs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_hash"
    t.string "role", default: "user"
    t.boolean "active", default: true
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vector_embeddings", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.text "content_chunk", null: false
    t.json "embedding_vector", null: false
    t.integer "chunk_index", null: false
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id", "chunk_index"], name: "index_vector_embeddings_on_document_id_and_chunk_index", unique: true
    t.index ["document_id"], name: "index_vector_embeddings_on_document_id"
  end

  add_foreign_key "audit_logs", "users", on_delete: :nullify
  add_foreign_key "documents", "users", on_delete: :cascade
  add_foreign_key "evaluation_jobs", "documents", column: "cv_document_id"
  add_foreign_key "evaluation_jobs", "documents", column: "project_document_id"
  add_foreign_key "evaluation_jobs", "users", on_delete: :cascade
  add_foreign_key "vector_embeddings", "documents"
end
