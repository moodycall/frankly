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

ActiveRecord::Schema.define(version: 20150626175945) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availability_intervals", force: true do |t|
    t.integer  "day_of_week",   default: 1, null: false
    t.integer  "counselor_id"
    t.string   "start_time"
    t.string   "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone_name"
  end

  create_table "counseling_certifications", force: true do |t|
    t.string   "name"
    t.integer  "counselor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counseling_degrees", force: true do |t|
    t.integer  "counselor_id"
    t.string   "degree_type"
    t.string   "name"
    t.string   "institution"
    t.string   "year_of_completion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counseling_licenses", force: true do |t|
    t.string   "license_number"
    t.string   "state"
    t.string   "established_on_date"
    t.integer  "counselor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "license_type"
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
    t.string   "opentok_session_id"
    t.string   "stripe_balance_transaction_id"
    t.integer  "stripe_processing_fee_in_cents"
    t.datetime "cancelled_on_dts"
    t.string   "stripe_refund_id"
  end

  create_table "counselors", force: true do |t|
    t.text     "bio"
    t.string   "profession_start_date"
    t.string   "slug"
    t.integer  "user_id"
    t.integer  "hourly_rate_in_cents",         default: 6000,  null: false
    t.integer  "hourly_fee_in_cents",          default: 1500,  null: false
    t.boolean  "send_session_sms_alerts",      default: false, null: false
    t.boolean  "send_session_email_alerts",    default: true,  null: false
    t.integer  "advanced_scheduling_in_weeks", default: 4,     null: false
    t.boolean  "available_monday",             default: false, null: false
    t.boolean  "available_tuesday",            default: false, null: false
    t.boolean  "available_wednesday",          default: false, null: false
    t.boolean  "available_thursday",           default: false, null: false
    t.boolean  "available_friday",             default: false, null: false
    t.boolean  "available_saturday",           default: false, null: false
    t.boolean  "available_sunday",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo"
    t.boolean  "is_active",                    default: false, null: false
  end

  create_table "credit_cards", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "stripe_card_id"
    t.boolean  "is_active",      default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_four"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "payouts", force: true do |t|
    t.integer  "user_id"
    t.integer  "total_in_cents"
    t.string   "stripe_transfer_id"
    t.datetime "funds_sent_dts"
    t.string   "slug"
    t.string   "secure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_balance_transaction_id"
    t.integer  "stripe_processing_fee_in_cents"
  end

  create_table "prompts", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "quantity",            default: 1,    null: false
    t.integer  "interval",            default: 1,    null: false
    t.boolean  "send_before_session", default: true, null: false
    t.boolean  "enable_sms",          default: true, null: false
    t.text     "sms_message"
    t.boolean  "enable_email",        default: true, null: false
    t.text     "email_message"
    t.integer  "audience_type",       default: 1,    null: false
    t.boolean  "is_active",           default: true, null: false
    t.string   "secure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  add_index "ratings", ["rateable_id", "rateable_type"], name: "index_ratings_on_rateable_id_and_rateable_type", using: :btree
  add_index "ratings", ["rater_id", "rater_type"], name: "index_ratings_on_rater_id_and_rater_type", using: :btree

  create_table "session_prompts", force: true do |t|
    t.integer  "prompt_id"
    t.integer  "counseling_session_id"
    t.integer  "user_id"
    t.datetime "scheduled_send_dts"
    t.datetime "sent_email_dts"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_sms_dts"
  end

  create_table "specializations", force: true do |t|
    t.integer  "specialty_id"
    t.integer  "counselor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specialties", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.boolean  "is_active",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                       default: "",    null: false
    t.string   "encrypted_password",          default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",             default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "phone"
    t.integer  "gender",                      default: 1,     null: false
    t.boolean  "send_session_email_alerts",   default: true,  null: false
    t.boolean  "send_session_sms_alerts",     default: false, null: false
    t.string   "stripe_recipient_id"
    t.string   "stripe_customer_id"
    t.string   "preferred_timezone"
    t.string   "photo"
    t.boolean  "is_admin",                    default: false, null: false
    t.datetime "sent_initial_cc_request_dts"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "last_name"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
