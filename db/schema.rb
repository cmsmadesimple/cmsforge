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

ActiveRecord::Schema.define(:version => 20090708214308) do

  create_table "articles", :force => true do |t|
    t.integer  "project_id"
    t.string   "title"
    t.text     "content"
    t.integer  "submitted_by"
    t.boolean  "is_on_front_page", :default => false
    t.boolean  "is_active",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bug_versions", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",  :default => true, :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.datetime "created_at",                                     :null => false
    t.integer  "commentable_id",                 :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",                        :default => 0,  :null => false
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enumrecords", :force => true do |t|
    t.string  "name"
    t.string  "type"
    t.integer "position", :default => 1
  end

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",   :null => false
    t.string   "followable_type", :null => false
    t.integer  "follower_id",     :null => false
    t.string   "follower_type",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"
  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"

  create_table "histories", :force => true do |t|
    t.integer  "historizable_id",   :null => false
    t.string   "historizable_type", :null => false
    t.datetime "created_at",        :null => false
  end

  create_table "history_lines", :force => true do |t|
    t.integer "history_id",         :null => false
    t.string  "field_name",         :null => false
    t.string  "field_value_was",    :null => false
    t.string  "field_value_actual", :null => false
  end

  create_table "licenses", :force => true do |t|
    t.string "name"
  end

  create_table "packages", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.boolean  "is_public",  :default => true
    t.boolean  "is_active",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_join_requests", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.text     "message"
    t.string   "state",      :default => "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "unix_name"
    t.text     "description"
    t.text     "registration_reason"
    t.string   "project_type"
    t.string   "project_category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                :default => "pending"
    t.datetime "approved_on"
    t.integer  "approved_by"
    t.text     "reject_reason"
    t.integer  "license_id"
    t.text     "changelog"
    t.text     "roadmap"
    t.integer  "downloads"
    t.datetime "next_planned_release"
    t.string   "repository_type",      :default => "svn"
    t.boolean  "show_join_request",    :default => false
  end

  create_table "released_files", :force => true do |t|
    t.integer  "release_id"
    t.string   "filename"
    t.integer  "size"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "downloads"
    t.string   "content_type"
  end

  create_table "releases", :force => true do |t|
    t.integer  "package_id"
    t.string   "name"
    t.text     "release_notes"
    t.text     "changelog"
    t.integer  "released_by"
    t.boolean  "is_active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ssh_keys", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tasks", :force => true do |t|
  end

  create_table "tracker_items", :force => true do |t|
    t.integer  "project_id"
    t.integer  "assigned_to_id"
    t.integer  "version_id"
    t.integer  "created_by_id"
    t.integer  "severity_id"
    t.string   "state"
    t.string   "summary"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resolution_id"
    t.string   "type",           :limit => 50
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "superuser",                               :default => false
    t.string   "full_name"
    t.string   "password_reset_code",       :limit => 40
  end

end
