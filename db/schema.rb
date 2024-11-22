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

ActiveRecord::Schema[7.1].define(version: 2024_11_22_144610) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "master", force: :cascade do |t|
    t.string "file_name"
    t.date "date"
    t.string "mobile"
    t.string "nationality"
    t.string "procedure"
    t.string "procedure_name"
    t.decimal "amount", precision: 15, scale: 2
    t.string "area_name"
    t.string "combine"
    t.string "master_project"
    t.string "project"
    t.string "plot_pre_reg_num"
    t.string "building_num"
    t.string "building_name"
    t.string "size"
    t.string "unit_number"
    t.string "dm_num"
    t.string "dm_sub_num"
    t.string "property_type"
    t.string "land_number"
    t.string "phone"
    t.string "secondary_mobile_number"
    t.string "id_number"
    t.string "uae_id"
    t.date "passport_expiry_date"
    t.date "birthdate"
    t.string "unified_num"
    t.string "email"
    t.text "extra_info_1"
    t.text "extra_info_2"
    t.text "extra_info_3"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "role", default: "user"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "email_confirmation_token"
    t.string "phone"
    t.datetime "email_confirmed_at"
    t.datetime "email_confirmation_sent_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "phone_confirmation_token"
    t.datetime "phone_confirmed_at"
    t.datetime "phone_confirmation_sent_at"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["is_deleted"], name: "index_users_on_is_deleted"
    t.index ["phone"], name: "index_users_on_phone"
    t.index ["phone_confirmation_token"], name: "index_users_on_phone_confirmation_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

end
