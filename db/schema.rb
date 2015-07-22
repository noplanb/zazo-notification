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

ActiveRecord::Schema.define(version: 20150624105446) do

  create_table "connections", force: :cascade do |t|
    t.integer  "creator_id", limit: 4
    t.integer  "target_id",  limit: 4
    t.string   "status",     limit: 255
    t.string   "ckey",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["ckey"], name: "index_connections_on_ckey", using: :btree
  add_index "connections", ["creator_id"], name: "index_connections_on_creator_id", using: :btree
  add_index "connections", ["target_id"], name: "index_connections_on_target_id", using: :btree

  create_table "kvstores", force: :cascade do |t|
    t.string   "key1",       limit: 255
    t.string   "key2",       limit: 255
    t.string   "value",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kvstores", ["key1"], name: "index_kvstores_on_key1", using: :btree

  create_table "push_users", force: :cascade do |t|
    t.string   "mkey",            limit: 255
    t.string   "push_token",      limit: 255
    t.string   "device_platform", limit: 255
    t.string   "device_build",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "push_users", ["mkey"], name: "index_push_users_on_mkey", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "mobile_number",          limit: 255
    t.text     "emails",                 limit: 65535
    t.string   "user_name",              limit: 255
    t.string   "device_platform",        limit: 255
    t.string   "auth",                   limit: 255
    t.string   "mkey",                   limit: 255
    t.string   "verification_code",      limit: 255
    t.datetime "verification_date_time"
    t.string   "status",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["mkey"], name: "index_users_on_mkey", using: :btree
  add_index "users", ["mobile_number"], name: "index_users_on_mobile_number", using: :btree

end
