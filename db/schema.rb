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

ActiveRecord::Schema.define(version: 20140121192330) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "disciplines", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inscriptions", force: true do |t|
    t.datetime "shift_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "shift_id"
  end

  add_index "inscriptions", ["shift_id"], name: "index_inscriptions_on_shift_id", using: :btree
  add_index "inscriptions", ["user_id"], name: "index_inscriptions_on_user_id", using: :btree

  create_table "instructors", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "amount"
    t.integer  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "month"
    t.datetime "deleted_at"
    t.integer  "year",       default: 2014
  end

  add_index "payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string "name"
  end

  create_table "shifts", force: true do |t|
    t.string   "day"
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "open_inscription"
    t.integer  "close_inscription"
    t.integer  "max_attendants"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discipline_id"
    t.integer  "instructor_id"
  end

  add_index "shifts", ["discipline_id"], name: "index_shifts_on_discipline_id", using: :btree
  add_index "shifts", ["instructor_id"], name: "index_shifts_on_instructor_id", using: :btree

  create_table "stats", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.integer  "role_id"
    t.integer  "credit"
    t.datetime "deleted_at"
    t.boolean  "reset_credit",           default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

end
