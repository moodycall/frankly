# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141217165747) do

  create_table "availability_intervals", force: true do |t|
    t.integer  "day_of_week",  default: 1, null: false
    t.integer  "counselor_id"
    t.string   "start_time"
    t.string   "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counseling_sessions", force: true do |t|
    t.datetime "start_datetime"
    t.integer  "estimate_duration_in_minutes"
    t.integer  "actual_duration_in_minutes"
    t.integer  "client_id"
    t.integer  "counselor_id"
    t.integer  "price_in_cents"
    t.string   "stripe_charge_id"
    t.string   "slug"
    t.string   "secure_id"
    t.integer  "refund_amount_in_cents"
    t.integer  "payout_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counselors", force: true do |t|
    t.text     "bio"
    t.date     "profession_start_date"
    t.string   "slug"
    t.integer  "user_id"
    t.integer  "hourly_rate_in_cents",         default: 6000,  null: false
    t.integer  "hourly_fee_in_cents",          default: 600,   null: false
    t.boolean  "send_session_sms_alerts",      default: false, null: false
    t.boolean  "send_session_email_alerts",    default: true,  null: false
    t.integer  "advanced_scheduling_in_weeks", default: 4,     null: false
    t.boolean  "available_monday",             default: true,  null: false
    t.boolean  "available_tuesday",            default: true,  null: false
    t.boolean  "available_wednesday",          default: true,  null: false
    t.boolean  "available_thursday",           default: true,  null: false
    t.boolean  "available_friday",             default: true,  null: false
    t.boolean  "available_saturday",           default: false, null: false
    t.boolean  "available_sunday",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_cards", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "stripe_card_id"
    t.boolean  "is_active",      default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorite_counselors", force: true do |t|
    t.integer  "user_id"
    t.integer  "counselor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "ratings", force: true do |t|
    t.integer  "rater_id",              null: false
    t.string   "rater_type",            null: false
    t.integer  "rateable_id",           null: false
    t.string   "rateable_type",         null: false
    t.text     "comment"
    t.integer  "stars",                 null: false
    t.integer  "counseling_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rateable_id", "rateable_type"], name: "index_ratings_on_rateable_id_and_rateable_type"
  add_index "ratings", ["rater_id", "rater_type"], name: "index_ratings_on_rater_id_and_rater_type"

  create_table "users", force: true do |t|
    t.string   "email",                     default: "",    null: false
    t.string   "encrypted_password",        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",           default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "phone"
    t.integer  "gender",                    default: 1,     null: false
    t.boolean  "send_session_email_alerts", default: true,  null: false
    t.boolean  "send_session_sms_alerts",   default: false, null: false
    t.string   "stripe_recipient_id"
    t.string   "stripe_customer_id"
    t.string   "preferred_timezone"
    t.string   "photo"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

end
