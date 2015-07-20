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

ActiveRecord::Schema.define(version: 20150514072333) do

  create_table "domains", force: :cascade do |t|
    t.string   "domain",           limit: 255
    t.string   "created_time",     limit: 255
    t.string   "updated_time",     limit: 255
    t.string   "expired_time",     limit: 255
    t.string   "registrant_org",   limit: 255
    t.string   "related_email",    limit: 255
    t.string   "related_country",  limit: 255
    t.integer  "nameserver_count", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "domains", ["domain"], name: "index_domains_on_domain", unique: true, using: :btree

  create_table "ip_asn_mappers", force: :cascade do |t|
    t.string   "ip",             limit: 255
    t.string   "as_number",      limit: 255
    t.string   "prefix",         limit: 255
    t.string   "country",        limit: 255
    t.string   "registry",       limit: 255
    t.string   "allocated_date", limit: 255
    t.string   "as_name",        limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
