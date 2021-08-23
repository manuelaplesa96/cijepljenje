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

ActiveRecord::Schema.define(version: 2021_08_02_100706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "vaccination_location_id"
    t.bigint "location_and_time_slot_id"
    t.string "author_type"
    t.bigint "author_id"
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.string "gender"
    t.bigint "oib"
    t.bigint "mbo"
    t.string "email"
    t.string "sector"
    t.bigint "phone_number"
    t.boolean "chronic_patient"
    t.string "status", default: "u obradi", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.index ["author_type", "author_id"], name: "index_applications_on_author_type_and_author_id"
    t.index ["location_and_time_slot_id"], name: "index_applications_on_location_and_time_slot_id"
    t.index ["vaccination_location_id"], name: "index_applications_on_vaccination_location_id"
  end

  create_table "doctors", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.bigint "admin_id"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_doctors_on_admin_id"
  end

  create_table "location_and_time_slots", force: :cascade do |t|
    t.bigint "vaccination_location_id"
    t.bigint "vaccination_time_slot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vaccine_id"
    t.index ["vaccination_location_id"], name: "index_location_and_time_slots_on_vaccination_location_id"
    t.index ["vaccination_time_slot_id"], name: "index_location_and_time_slots_on_vaccination_time_slot_id"
    t.index ["vaccine_id"], name: "index_location_and_time_slots_on_vaccine_id"
  end

  create_table "super_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.bigint "admin_id"
    t.string "sector"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_super_users_on_admin_id"
  end

  create_table "vaccination_locations", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "county"
    t.bigint "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_vaccination_locations_on_admin_id"
  end

  create_table "vaccination_time_slots", force: :cascade do |t|
    t.datetime "date_and_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vaccination_workers", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.bigint "admin_id"
    t.bigint "vaccination_location_id"
    t.string "start_work_time"
    t.string "end_work_time"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_vaccination_workers_on_admin_id"
    t.index ["vaccination_location_id"], name: "index_vaccination_workers_on_vaccination_location_id"
  end

  create_table "vaccinations", force: :cascade do |t|
    t.bigint "application_id"
    t.bigint "vaccine_id"
    t.bigint "vaccination_time_slot_id"
    t.bigint "vaccination_worker_id"
    t.integer "dose_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_vaccinations_on_application_id"
    t.index ["vaccination_time_slot_id"], name: "index_vaccinations_on_vaccination_time_slot_id"
    t.index ["vaccination_worker_id"], name: "index_vaccinations_on_vaccination_worker_id"
    t.index ["vaccine_id"], name: "index_vaccinations_on_vaccine_id"
  end

  create_table "vaccines", force: :cascade do |t|
    t.bigint "admin_id"
    t.bigint "vaccination_location_id"
    t.string "name"
    t.string "series"
    t.integer "doses_number"
    t.integer "amount"
    t.integer "min_days_between_doses"
    t.integer "max_days_between_doses"
    t.datetime "start_date"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_vaccines_on_admin_id"
    t.index ["vaccination_location_id"], name: "index_vaccines_on_vaccination_location_id"
  end

  add_foreign_key "applications", "location_and_time_slots"
  add_foreign_key "applications", "vaccination_locations"
  add_foreign_key "doctors", "admins"
  add_foreign_key "location_and_time_slots", "vaccination_locations"
  add_foreign_key "location_and_time_slots", "vaccination_time_slots"
  add_foreign_key "location_and_time_slots", "vaccines"
  add_foreign_key "super_users", "admins"
  add_foreign_key "vaccination_locations", "admins"
  add_foreign_key "vaccination_workers", "admins"
  add_foreign_key "vaccination_workers", "vaccination_locations"
  add_foreign_key "vaccinations", "applications"
  add_foreign_key "vaccinations", "vaccination_time_slots"
  add_foreign_key "vaccinations", "vaccination_workers"
  add_foreign_key "vaccinations", "vaccines"
  add_foreign_key "vaccines", "admins"
  add_foreign_key "vaccines", "vaccination_locations"
end
