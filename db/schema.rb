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

ActiveRecord::Schema[7.1].define(version: 2025_10_06_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["checksum"], name: "index_documents_on_checksum"
    t.index ["document_type"], name: "index_documents_on_document_type"
    t.index ["processed"], name: "index_documents_on_processed"
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
    t.index ["created_at"], name: "index_evaluation_jobs_on_created_at"
    t.index ["cv_document_id"], name: "index_evaluation_jobs_on_cv_document_id"
    t.index ["job_id"], name: "index_evaluation_jobs_on_job_id", unique: true
    t.index ["job_title"], name: "index_evaluation_jobs_on_job_title"
    t.index ["project_document_id"], name: "index_evaluation_jobs_on_project_document_id"
    t.index ["status"], name: "index_evaluation_jobs_on_status"
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

  add_foreign_key "evaluation_jobs", "documents", column: "cv_document_id"
  add_foreign_key "evaluation_jobs", "documents", column: "project_document_id"
  add_foreign_key "vector_embeddings", "documents"
end
