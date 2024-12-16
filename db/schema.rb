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

ActiveRecord::Schema[7.1].define(version: 2024_12_15_051229) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "broadcast_reports", force: :cascade do |t|
    t.bigint "broadcast_id"
    t.string "broadcast_name"
    t.string "mobile"
    t.string "nationality"
    t.datetime "sent_on"
    t.datetime "delivered_on"
    t.datetime "seen_on"
    t.integer "message_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "whatsapp_message_id"
    t.string "reason_for_failure"
    t.string "name"
    t.index ["broadcast_id"], name: "index_broadcast_reports_on_broadcast_id"
  end

  create_table "broadcasts", force: :cascade do |t|
    t.string "name"
    t.bigint "whatsapp_account_id"
    t.bigint "template_id"
    t.bigint "master_segment_id"
    t.integer "timing", null: false
    t.bigint "added_by_id"
    t.bigint "edited_by_id"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "scheduled_at"
    t.index ["added_by_id"], name: "index_broadcasts_on_added_by_id"
    t.index ["deleted_by_id"], name: "index_broadcasts_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_broadcasts_on_edited_by_id"
    t.index ["master_segment_id"], name: "index_broadcasts_on_master_segment_id"
    t.index ["template_id"], name: "index_broadcasts_on_template_id"
    t.index ["whatsapp_account_id"], name: "index_broadcasts_on_whatsapp_account_id"
  end

  create_table "chatbot_button_replies", force: :cascade do |t|
    t.bigint "chatbot_id", null: false
    t.bigint "chatbot_step_id", null: false
    t.integer "action_type_id"
    t.integer "order"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "added_by_id"
    t.datetime "added_on"
    t.bigint "edited_by_id"
    t.datetime "edited_on"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.index ["added_by_id"], name: "index_chatbot_button_replies_on_added_by_id"
    t.index ["chatbot_id"], name: "index_chatbot_button_replies_on_chatbot_id"
    t.index ["chatbot_step_id"], name: "index_chatbot_button_replies_on_chatbot_step_id"
    t.index ["deleted_by_id"], name: "index_chatbot_button_replies_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_chatbot_button_replies_on_edited_by_id"
  end

  create_table "chatbot_location_replies", force: :cascade do |t|
    t.string "location_name"
    t.string "location_address"
    t.decimal "location_latitude", precision: 10, scale: 6
    t.decimal "location_longitude", precision: 10, scale: 6
    t.bigint "chatbot_id"
    t.bigint "chatbot_step_id"
    t.integer "order"
    t.bigint "added_by_id"
    t.datetime "added_on"
    t.bigint "edited_by_id"
    t.datetime "edited_on"
    t.bigint "deleted_by_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_chatbot_location_replies_on_added_by_id"
    t.index ["chatbot_id"], name: "index_chatbot_location_replies_on_chatbot_id"
    t.index ["chatbot_step_id"], name: "index_chatbot_location_replies_on_chatbot_step_id"
    t.index ["deleted_by_id"], name: "index_chatbot_location_replies_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_chatbot_location_replies_on_edited_by_id"
  end

  create_table "chatbot_multimedia_replies", force: :cascade do |t|
    t.bigint "chatbot_id"
    t.bigint "chatbot_step_id"
    t.integer "media_type_id"
    t.integer "order"
    t.text "text_body"
    t.string "file_caption"
    t.bigint "added_by_id"
    t.datetime "added_on"
    t.bigint "edited_by_id"
    t.datetime "edited_on"
    t.bigint "deleted_by_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_chatbot_multimedia_replies_on_added_by_id"
    t.index ["chatbot_id"], name: "index_chatbot_multimedia_replies_on_chatbot_id"
    t.index ["chatbot_step_id"], name: "index_chatbot_multimedia_replies_on_chatbot_step_id"
    t.index ["deleted_by_id"], name: "index_chatbot_multimedia_replies_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_chatbot_multimedia_replies_on_edited_by_id"
  end

  create_table "chatbot_steps", force: :cascade do |t|
    t.bigint "chatbot_id"
    t.bigint "previous_chatbot_step_id"
    t.string "header"
    t.text "description"
    t.string "footer"
    t.string "list_button_caption"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.bigint "edited_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "chatbot_button_reply_id"
    t.index ["chatbot_button_reply_id"], name: "index_chatbot_steps_on_chatbot_button_reply_id"
    t.index ["chatbot_id"], name: "index_chatbot_steps_on_chatbot_id"
    t.index ["created_by_id"], name: "index_chatbot_steps_on_created_by_id"
    t.index ["deleted_by_id"], name: "index_chatbot_steps_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_chatbot_steps_on_edited_by_id"
    t.index ["previous_chatbot_step_id"], name: "index_chatbot_steps_on_previous_chatbot_step_id"
  end

  create_table "chatbots", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.bigint "created_by_id"
    t.bigint "edited_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_chatbots_on_created_by_id"
    t.index ["deleted_by_id"], name: "index_chatbots_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_chatbots_on_edited_by_id"
  end

  create_table "chatbots_master_segments", id: false, force: :cascade do |t|
    t.bigint "chatbot_id", null: false
    t.bigint "master_segment_id", null: false
    t.index ["chatbot_id"], name: "index_chatbots_master_segments_on_chatbot_id"
    t.index ["master_segment_id"], name: "index_chatbots_master_segments_on_master_segment_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "mobile_number"
    t.boolean "is_from_chat_bot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "document_url"
    t.string "file_caption"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "location_name"
    t.string "location_description"
    t.jsonb "text"
  end

  create_table "master_segments", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "added_by_id"
    t.datetime "added_on"
    t.bigint "edited_by_id"
    t.datetime "edited_on"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "table_type_id"
    t.index ["added_by_id"], name: "index_master_segments_on_added_by_id"
    t.index ["deleted_by_id"], name: "index_master_segments_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_master_segments_on_edited_by_id"
  end

  create_table "masters", force: :cascade do |t|
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
    t.string "name"
    t.string "land_sub_num"
  end

  create_table "segments", force: :cascade do |t|
    t.integer "table_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "added_by_id"
    t.datetime "added_on"
    t.bigint "edited_by_id"
    t.datetime "edited_on"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.bigint "master_segment_id", null: false
    t.string "mobile"
    t.string "person_name"
    t.string "person_email"
    t.string "nationality"
    t.index ["added_by_id"], name: "index_segments_on_added_by_id"
    t.index ["deleted_by_id"], name: "index_segments_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_segments_on_edited_by_id"
    t.index ["master_segment_id"], name: "index_segments_on_master_segment_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.string "meta_template_name"
    t.string "language"
    t.string "component"
    t.bigint "added_by_id"
    t.bigint "edited_by_id"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_templates_on_added_by_id"
    t.index ["deleted_by_id"], name: "index_templates_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_templates_on_edited_by_id"
  end

  create_table "user_chatbot_interactions", force: :cascade do |t|
    t.bigint "chatbot_step_id", null: false
    t.string "clicked_button_id"
    t.string "mobile_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chatbot_step_id"], name: "index_user_chatbot_interactions_on_chatbot_step_id"
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

  create_table "whatsapp_accounts", force: :cascade do |t|
    t.string "name"
    t.string "whatsapp_mobile_number"
    t.string "app_id"
    t.string "phone_number_id"
    t.string "whatsapp_business_account_id"
    t.string "token"
    t.string "webhook_version"
    t.bigint "added_by_id"
    t.bigint "edited_by_id"
    t.boolean "is_deleted", default: false
    t.bigint "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_whatsapp_accounts_on_added_by_id"
    t.index ["deleted_by_id"], name: "index_whatsapp_accounts_on_deleted_by_id"
    t.index ["edited_by_id"], name: "index_whatsapp_accounts_on_edited_by_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "broadcast_reports", "broadcasts"
  add_foreign_key "broadcasts", "master_segments"
  add_foreign_key "broadcasts", "templates"
  add_foreign_key "broadcasts", "users", column: "added_by_id"
  add_foreign_key "broadcasts", "users", column: "deleted_by_id"
  add_foreign_key "broadcasts", "users", column: "edited_by_id"
  add_foreign_key "broadcasts", "whatsapp_accounts"
  add_foreign_key "chatbot_button_replies", "chatbot_steps"
  add_foreign_key "chatbot_button_replies", "chatbots"
  add_foreign_key "chatbot_button_replies", "users", column: "added_by_id"
  add_foreign_key "chatbot_button_replies", "users", column: "deleted_by_id"
  add_foreign_key "chatbot_button_replies", "users", column: "edited_by_id"
  add_foreign_key "chatbot_location_replies", "chatbot_steps"
  add_foreign_key "chatbot_location_replies", "chatbots"
  add_foreign_key "chatbot_location_replies", "users", column: "added_by_id"
  add_foreign_key "chatbot_location_replies", "users", column: "deleted_by_id"
  add_foreign_key "chatbot_location_replies", "users", column: "edited_by_id"
  add_foreign_key "chatbot_multimedia_replies", "chatbot_steps"
  add_foreign_key "chatbot_multimedia_replies", "chatbots"
  add_foreign_key "chatbot_multimedia_replies", "users", column: "added_by_id"
  add_foreign_key "chatbot_multimedia_replies", "users", column: "deleted_by_id"
  add_foreign_key "chatbot_multimedia_replies", "users", column: "edited_by_id"
  add_foreign_key "chatbot_steps", "chatbot_button_replies"
  add_foreign_key "chatbot_steps", "chatbot_steps", column: "previous_chatbot_step_id"
  add_foreign_key "chatbot_steps", "chatbots"
  add_foreign_key "chatbot_steps", "users", column: "created_by_id"
  add_foreign_key "chatbot_steps", "users", column: "deleted_by_id"
  add_foreign_key "chatbot_steps", "users", column: "edited_by_id"
  add_foreign_key "chatbots", "users", column: "created_by_id"
  add_foreign_key "chatbots", "users", column: "deleted_by_id"
  add_foreign_key "chatbots", "users", column: "edited_by_id"
  add_foreign_key "master_segments", "users", column: "added_by_id"
  add_foreign_key "master_segments", "users", column: "deleted_by_id"
  add_foreign_key "master_segments", "users", column: "edited_by_id"
  add_foreign_key "segments", "master_segments"
  add_foreign_key "segments", "users", column: "added_by_id"
  add_foreign_key "segments", "users", column: "deleted_by_id"
  add_foreign_key "segments", "users", column: "edited_by_id"
  add_foreign_key "templates", "users", column: "added_by_id"
  add_foreign_key "templates", "users", column: "deleted_by_id"
  add_foreign_key "templates", "users", column: "edited_by_id"
  add_foreign_key "user_chatbot_interactions", "chatbot_steps"
  add_foreign_key "whatsapp_accounts", "users", column: "added_by_id"
  add_foreign_key "whatsapp_accounts", "users", column: "deleted_by_id"
  add_foreign_key "whatsapp_accounts", "users", column: "edited_by_id"
end
