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

ActiveRecord::Schema.define(version: 20150207192214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.string   "title",      default: "", null: false
    t.datetime "due_at"
    t.datetime "checked_at"
    t.string   "body",       default: "", null: false
    t.string   "gist_id"
    t.integer  "team_id"
  end

  add_index "assignments", ["team_id"], name: "index_assignments_on_team_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "solution_id", null: false
    t.integer  "user_id",     null: false
    t.integer  "remote_id",   null: false
    t.text     "body",        null: false
    t.datetime "created_at",  null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string  "organization"
    t.string  "name"
    t.integer "organization_id"
    t.integer "team_id"
    t.string  "issues_repo"
    t.integer "repo_id"
    t.integer "admin_id"
  end

  create_table "solutions", force: :cascade do |t|
    t.integer  "assignment_id",                 null: false
    t.integer  "user_id",                       null: false
    t.string   "repo",                          null: false
    t.integer  "number"
    t.datetime "completed_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "solution_url"
    t.boolean  "reviewed",      default: false, null: false
  end

  create_table "team_memberships", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "user_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "",                           null: false
    t.string   "name",                default: "",                           null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "github_username"
    t.integer  "active_team_id"
    t.string   "github_access_token"
    t.boolean  "admin",               default: false
    t.text     "github_data"
    t.string   "time_zone",           default: "Eastern Time (US & Canada)"
  end

  add_index "users", ["github_username"], name: "index_users_on_github_username", using: :btree

end
