# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_11_182014) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jobs", force: :cascade do |t|
    t.boolean "action_required", default: true, null: false
    t.boolean "application_active", default: true, null: false
    t.string "application_status", null: false
    t.string "company_name", null: false
    t.jsonb "data", default: {}, null: false
    t.text "notes", default: "", null: false
    t.string "source", null: false
    t.jsonb "source_data", default: {}, null: false
    t.string "time_period", null: false
    t.string "title", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action_required", "company_name"], name: "index_jobs_on_action_required_and_company_name"
    t.index ["application_status", "company_name"], name: "index_jobs_on_application_status_and_company_name"
    t.index ["company_name"], name: "index_jobs_on_company_name"
  end

  create_table "time_periods", force: :cascade do |t|
    t.integer "month", null: false
    t.integer "year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["year", "month"], name: "index_time_periods_on_year_and_month", unique: true
  end

end
