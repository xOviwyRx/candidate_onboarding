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

ActiveRecord::Schema[8.0].define(version: 2026_07_20_122258) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.datetime "consent_given_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_candidate_profiles_on_email", unique: true
    t.index ["job_function"], name: "index_candidate_profiles_on_job_function"
    t.index ["search_status"], name: "index_candidate_profiles_on_search_status"
  end
end
