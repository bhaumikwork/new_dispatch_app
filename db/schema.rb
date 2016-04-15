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

ActiveRecord::Schema.define(version: 20160414061936) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dispatchers", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "first_name",             default: "", null: false
    t.string   "last_name",              default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "dispatchers", ["confirmation_token"], name: "index_dispatchers_on_confirmation_token", unique: true, using: :btree
  add_index "dispatchers", ["email"], name: "index_dispatchers_on_email", unique: true, using: :btree
  add_index "dispatchers", ["reset_password_token"], name: "index_dispatchers_on_reset_password_token", unique: true, using: :btree

  create_table "location_details", force: :cascade do |t|
    t.string   "dest_lat"
    t.string   "dest_long"
    t.string   "source_lat"
    t.string   "source_long"
    t.integer  "eta"
    t.string   "url_token"
    t.integer  "dispatcher_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "is_reached",               default: false
    t.string   "curr_lat"
    t.string   "curr_long"
    t.datetime "eta_calc_time"
    t.integer  "current_eta"
    t.integer  "dispatcher_refresh_count", default: 0
    t.boolean  "is_terminate",             default: false
    t.string   "image_url"
    t.integer  "next_refresh_second",      default: 0 # Not used this column in code
    t.integer  "status",                   default: 0
    t.float    "curr_mile",                default: 0.0
    t.datetime "next_refresh_time"
    t.datetime "tracking_start_time"
  end

  add_index "location_details", ["dispatcher_id"], name: "index_location_details_on_dispatcher_id", using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "vendors", ["email"], name: "index_vendors_on_email", unique: true, using: :btree
  add_index "vendors", ["reset_password_token"], name: "index_vendors_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "location_details", "dispatchers"
end
