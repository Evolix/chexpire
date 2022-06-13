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

ActiveRecord::Schema.define(version: 2019_08_16_223645) do

  create_table "check_logs", charset: "utf8", force: :cascade do |t|
    t.bigint "check_id"
    t.text "raw_response"
    t.integer "exit_status"
    t.text "parsed_response"
    t.text "error"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_id"], name: "index_check_logs_on_check_id"
  end

  create_table "check_notifications", charset: "utf8", force: :cascade do |t|
    t.bigint "check_id"
    t.bigint "notification_id"
    t.integer "status", limit: 1, default: 0, null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_id"], name: "index_check_notifications_on_check_id"
    t.index ["notification_id"], name: "index_check_notifications_on_notification_id"
  end

  create_table "checks", charset: "utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "kind", null: false
    t.string "domain", null: false
    t.datetime "domain_created_at"
    t.datetime "domain_updated_at"
    t.datetime "domain_expires_at"
    t.datetime "last_run_at"
    t.datetime "last_success_at"
    t.string "vendor"
    t.string "comment"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "round_robin", default: true
    t.integer "consecutive_failures", default: 0, null: false
    t.integer "mode", default: 0, null: false
    t.index ["user_id"], name: "index_checks_on_user_id"
  end

  create_table "notifications", charset: "utf8", force: :cascade do |t|
    t.bigint "check_id"
    t.integer "channel", default: 0, null: false
    t.string "recipient", null: false
    t.integer "interval", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "label"
    t.integer "checks_count", default: 0, null: false
    t.index ["check_id"], name: "index_notifications_on_check_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "users", charset: "utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "tos_accepted", default: false, null: false
    t.boolean "notifications_enabled", default: true, null: false
    t.string "locale", limit: 5, default: "en", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "check_logs", "checks"
  add_foreign_key "check_notifications", "checks"
  add_foreign_key "check_notifications", "notifications"
  add_foreign_key "checks", "users"
  add_foreign_key "notifications", "checks"
  add_foreign_key "notifications", "users"
end
