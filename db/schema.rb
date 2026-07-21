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

ActiveRecord::Schema[8.0].define(version: 2026_07_21_151641) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "candidate_documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "candidate_profile_id"
    t.string "document_type", null: false
    t.string "original_filename", null: false
    t.string "content_type", null: false
    t.integer "file_size", null: false
    t.datetime "parsed_at"
    t.string "parsing_status", default: "pending", null: false
    t.jsonb "parsed_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id"], name: "index_candidate_documents_on_candidate_profile_id"
    t.index ["user_id"], name: "index_candidate_documents_on_user_id"
  end

  create_table "candidate_profiles", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone_number", null: false
    t.string "city", null: false
    t.string "country"
    t.string "job_function", null: false
    t.string "preferred_regions", default: [], null: false, array: true
    t.integer "max_travel_time", null: false
    t.string "transport_types", default: [], null: false, array: true
    t.string "search_status", null: false
    t.text "reason_for_looking"
    t.string "employment_types", default: [], null: false, array: true
    t.decimal "desired_gross_salary", precision: 10, scale: 2
    t.decimal "desired_percentage", precision: 5, scale: 2
    t.decimal "average_daily_revenue", precision: 10, scale: 2
    t.string "big_registration_status"
    t.string "big_number"
    t.decimal "years_of_experience", precision: 3, scale: 1, null: false
    t.string "available_working_days", default: [], null: false, array: true
    t.date "available_from", null: false
    t.string "notice_period"
    t.text "motivation_for_employer"
    t.text "internal_notes"
    t.text "professional_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["email"], name: "index_candidate_profiles_on_email", unique: true
    t.index ["job_function"], name: "index_candidate_profiles_on_job_function"
    t.index ["search_status"], name: "index_candidate_profiles_on_search_status"
    t.index ["user_id"], name: "index_candidate_profiles_on_user_id", unique: true
  end

  create_table "educations", force: :cascade do |t|
    t.bigint "candidate_profile_id", null: false
    t.string "institution"
    t.string "study", null: false
    t.string "location"
    t.string "level"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id"], name: "index_educations_on_candidate_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "consent_given_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "work_experiences", force: :cascade do |t|
    t.bigint "candidate_profile_id", null: false
    t.string "job_title", null: false
    t.string "company_name", null: false
    t.text "responsibilities"
    t.date "start_date"
    t.date "end_date"
    t.boolean "current_job", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_profile_id"], name: "index_work_experiences_on_candidate_profile_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "candidate_documents", "candidate_profiles"
  add_foreign_key "candidate_documents", "users"
  add_foreign_key "candidate_profiles", "users"
  add_foreign_key "educations", "candidate_profiles"
  add_foreign_key "work_experiences", "candidate_profiles"
end
