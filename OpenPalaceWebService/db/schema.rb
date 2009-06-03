# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090603061619) do

  create_table "palace_props", :force => true do |t|
    t.string   "guid",               :limit => 36
    t.string   "name",               :limit => 128
    t.integer  "width"
    t.integer  "height"
    t.integer  "offset_x"
    t.integer  "offset_y"
    t.integer  "legacy_id"
    t.integer  "legacy_crc"
    t.string   "originating_palace"
    t.boolean  "flag_head",                         :default => false
    t.boolean  "flag_ghost",                        :default => false
    t.boolean  "flag_rare",                         :default => false
    t.boolean  "flag_animate",                      :default => false
    t.boolean  "flag_palindrome",                   :default => false
    t.boolean  "flag_bounce",                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "palace_props", ["guid"], :name => "index_palace_props_on_guid"
  add_index "palace_props", ["legacy_crc"], :name => "index_palace_props_on_legacy_crc"
  add_index "palace_props", ["legacy_id"], :name => "index_palace_props_on_legacy_id"
  add_index "palace_props", ["originating_palace"], :name => "index_palace_props_on_originating_palace"

end
