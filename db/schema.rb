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

ActiveRecord::Schema.define(:version => 20130826003117) do

  create_table "configurations", :force => true do |t|
    t.integer  "node_id"
    t.integer  "flow_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flows", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "user_id"
    t.text     "hash_attributes"
    t.string   "body"
    t.string   "kind"
  end

  add_index "flows", ["name"], :name => "index_flows_on_name", :unique => true
  add_index "flows", ["user_id", "created_at"], :name => "index_flows_on_user_id_and_created_at"

  create_table "nodes", :force => true do |t|
    t.string   "ip"
    t.string   "hostname"
    t.string   "domain"
    t.string   "fqdn"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "user_id"
    t.string   "directory_path"
  end

  create_table "reports", :force => true do |t|
    t.string   "file_path"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "node_id"
    t.string   "name"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "super_admin"
    t.string   "directory_path"
    t.boolean  "marked_as_deletable"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
