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

ActiveRecord::Schema.define(version: 20151004123537) do

  create_table "disciplines", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",      limit: 255
    t.boolean  "default"
    t.string   "font_color", limit: 255
  end

  create_table "inscriptions", force: :cascade do |t|
    t.datetime "shift_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "shift_id",   limit: 4
    t.boolean  "attended",             default: false
  end

  add_index "inscriptions", ["shift_date"], name: "index_inscriptions_on_shift_date", using: :btree
  add_index "inscriptions", ["shift_id"], name: "index_inscriptions_on_shift_id", using: :btree
  add_index "inscriptions", ["user_id"], name: "index_inscriptions_on_user_id", using: :btree

  create_table "instructors", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "amount",      limit: 4
    t.integer  "credit",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     limit: 4
    t.datetime "deleted_at"
    t.integer  "used_credit", limit: 4, default: 0
    t.datetime "reset_date"
    t.date     "month_year"
  end

  add_index "payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "rookies", force: :cascade do |t|
    t.datetime "shift_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name",  limit: 255
    t.string   "phone",      limit: 255
    t.string   "email",      limit: 255
    t.string   "notes",      limit: 255
    t.integer  "shift_id",   limit: 4
    t.boolean  "attended",               default: false
  end

  add_index "rookies", ["shift_date"], name: "index_rookies_on_shift_date", using: :btree
  add_index "rookies", ["shift_id"], name: "index_rookies_on_shift_id", using: :btree

  create_table "shifts", force: :cascade do |t|
    t.integer  "week_day",           limit: 4
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "open_inscription",   limit: 4
    t.integer  "close_inscription",  limit: 4
    t.integer  "max_attendants",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discipline_id",      limit: 4
    t.integer  "instructor_id",      limit: 4
    t.integer  "cancel_inscription", limit: 4, default: 2
    t.datetime "deleted_at"
  end

  add_index "shifts", ["discipline_id"], name: "index_shifts_on_discipline_id", using: :btree
  add_index "shifts", ["instructor_id"], name: "index_shifts_on_instructor_id", using: :btree

  create_table "stats", force: :cascade do |t|
    t.date     "month_year"
    t.integer  "inscriptions", limit: 4
    t.integer  "credits",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_disciplines", force: :cascade do |t|
    t.integer "user_id",       limit: 4
    t.integer "discipline_id", limit: 4
  end

  add_index "user_disciplines", ["discipline_id"], name: "index_user_disciplines_on_discipline_id", using: :btree
  add_index "user_disciplines", ["user_id"], name: "index_user_disciplines_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",                    null: false
    t.string   "encrypted_password",     limit: 255, default: "",                    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "phone",                  limit: 255
    t.integer  "role_id",                limit: 4
    t.integer  "credit",                 limit: 4
    t.datetime "deleted_at"
    t.boolean  "reset_credit",                       default: true
    t.datetime "last_reset_date",                    default: '2014-03-05 02:00:00'
    t.boolean  "certificate",                        default: false
    t.boolean  "enable",                             default: true
    t.string   "profession",             limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

end
