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

ActiveRecord::Schema.define(:version => 20130207183232) do

  create_table "alerts", :force => true do |t|
    t.integer  "sensor_id"
    t.float    "value"
    t.float    "limit"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "measurements", :force => true do |t|
    t.integer  "sensor_id"
    t.float    "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "monitor_sensors", :force => true do |t|
    t.integer  "sensor_id"
    t.integer  "monitor_window_id"
    t.string   "legend"
    t.string   "color"
    t.string   "initial_window_token"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "monitor_windows", :force => true do |t|
    t.string   "monitor_type"
    t.string   "name"
    t.integer  "user_id"
    t.integer  "y_axis_min"
    t.boolean  "y_axis_min_auto"
    t.integer  "y_axis_max"
    t.boolean  "y_axis_max_auto"
    t.integer  "x_axis_days"
    t.boolean  "x_axis_auto"
    t.string   "background_color"
    t.boolean  "legend"
    t.boolean  "public"
    t.string   "url"
    t.string   "width"
    t.string   "initial_token"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.boolean  "background_color_auto"
  end

  create_table "sensor_types", :force => true do |t|
    t.string   "name"
    t.float    "offset"
    t.float    "scale"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sensors", :force => true do |t|
    t.string   "name"
    t.integer  "sensor_type_id"
    t.integer  "user_id"
    t.string   "group"
    t.string   "controller"
    t.integer  "addressH"
    t.integer  "addressL"
    t.float    "offset"
    t.float    "scale"
    t.integer  "interval"
    t.float    "trigger_upper_limit"
    t.float    "trigger_lower_limit"
    t.integer  "trigger_delay"
    t.string   "trigger_email"
    t.boolean  "trigger_enabled"
    t.boolean  "absence_alert"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "trigger_lower_name"
    t.string   "trigger_upper_name"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                  :default => false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "state"
    t.string   "confirmation_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
