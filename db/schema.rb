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

ActiveRecord::Schema.define(version: 20160416183030) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auctions", force: :cascade do |t|
    t.integer  "auc",            limit: 8
    t.integer  "item"
    t.string   "owner"
    t.string   "original_realm"
    t.integer  "bid",            limit: 8
    t.integer  "buyout",         limit: 8
    t.integer  "quantity"
    t.string   "time_left"
    t.integer  "rand"
    t.integer  "seed",           limit: 8
    t.integer  "context"
    t.integer  "pet_species_id"
    t.integer  "pet_breed_id"
    t.integer  "pet_level"
    t.integer  "pet_quality_id"
    t.integer  "realm_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "auctions", ["auc", "realm_id"], name: "index_auctions_on_auc_and_realm_id", unique: true, using: :btree

  create_table "realms", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "region"
    t.string   "realm_type"
    t.string   "population"
    t.string   "source_realm"
    t.text     "auction_url"
    t.datetime "last_modified"
    t.string   "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_foreign_key "auctions", "realms"
end
