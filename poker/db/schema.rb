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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120313045701) do

  create_table "players", :force => true do |t|
    t.string   "email",              :default => "",    :null => false
    t.string   "encrypted_password", :default => "",    :null => false
    t.string   "name"
    t.string   "card_1"
    t.string   "card_2"
    t.string   "token"
    t.datetime "left_game_at"
    t.integer  "money",              :default => 0
    t.boolean  "folded",             :default => false
    t.string   "last_action"
    t.integer  "table_id"
    t.integer  "tournament_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "players", ["email"], :name => "index_players_on_email", :unique => true

  create_table "players_pots", :id => false, :force => true do |t|
    t.integer "player_id"
    t.integer "pot_id"
  end

  add_index "players_pots", ["player_id", "pot_id"], :name => "index_players_pots_on_player_id_and_pot_id"
  add_index "players_pots", ["pot_id", "player_id"], :name => "index_players_pots_on_pot_id_and_player_id"

  create_table "pots", :force => true do |t|
    t.integer  "amount"
    t.integer  "table_id"
    t.string   "player_amounts"
    t.integer  "highest_bet"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "tables", :force => true do |t|
    t.string   "cards_on_table"
    t.string   "cards_in_deck"
    t.integer  "button",         :default => 0
    t.integer  "blind_amount"
    t.integer  "tournament_id"
    t.integer  "hands_played",   :default => 0
    t.integer  "player_turn",    :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

end
