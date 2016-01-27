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

ActiveRecord::Schema.define(version: 20151220080643) do

  create_table "game_teams", force: :cascade do |t|
    t.integer "game_id"
    t.integer "team_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "date"
  end

  create_table "player_positions", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "position_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "player_rosters", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "roster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: :cascade do |t|
    t.string  "name"
    t.integer "ranking"
    t.integer "team_id"
  end

  create_table "position_rosters", force: :cascade do |t|
    t.integer "roster_id"
    t.integer "position_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "name"
  end

  create_table "rosters", force: :cascade do |t|
    t.string   "name"
    t.integer  "player_max"
    t.integer  "user_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest"
  end

end
