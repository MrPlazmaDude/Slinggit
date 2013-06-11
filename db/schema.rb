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

ActiveRecord::Schema.define(:version => 20120814031952) do

  create_table "additional_photos", :force => true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.integer  "source_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "status"
  end

  create_table "api_accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "api_id"
    t.string   "api_id_hash"
    t.string   "api_source"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "real_name"
    t.string   "user_name"
    t.string   "image_url"
    t.string   "description"
    t.string   "language"
    t.string   "location"
    t.string   "status"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "reauth_required",  :default => "no"
    t.datetime "oauth_expiration"
  end

  create_table "comments", :force => true do |t|
    t.string   "body",       :limit => 350
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "status",                    :default => "ACT"
    t.string   "id_hash"
  end

  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "email_preferences", :force => true do |t|
    t.integer "user_id"
    t.boolean "system_emails"
    t.boolean "marketing_emails"
  end

  create_table "facebook_posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "api_account_id"
    t.integer  "post_id"
    t.string   "name"
    t.string   "message"
    t.string   "caption"
    t.string   "description"
    t.string   "image_url"
    t.string   "link_url"
    t.string   "facebook_post_id"
    t.string   "status"
    t.string   "last_result"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "flagged_contents", :force => true do |t|
    t.integer  "creator_user_id"
    t.string   "source"
    t.integer  "source_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "invitations", :force => true do |t|
    t.string   "email"
    t.text     "comment"
    t.string   "status",          :default => "pending"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "source_user_id"
    t.string   "activation_code"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_user_id"
    t.integer  "recipient_user_id"
    t.string   "source"
    t.integer  "source_id"
    t.string   "contact_info_json"
    t.string   "body",              :limit => 1200
    t.string   "status",                            :default => "UNR"
    t.string   "id_hash"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "parent_id"
    t.string   "thread_id"
    t.string   "recipient_status",                  :default => "UNR"
    t.string   "sender_status",                     :default => "UNR"
  end

  add_index "messages", ["id_hash"], :name => "index_messages_on_id_hash"
  add_index "messages", ["sender_user_id"], :name => "index_messages_on_creator_user_id"
  add_index "messages", ["source"], :name => "index_messages_on_source"
  add_index "messages", ["status"], :name => "index_messages_on_status"

  create_table "mobile_sessions", :force => true do |t|
    t.integer  "user_id"
    t.string   "unique_identifier"
    t.string   "mobile_auth_token"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "device_name"
    t.string   "ip_address"
    t.string   "options",           :limit => 1000
  end

  create_table "post_histories", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "content"
    t.datetime "created_at"
    t.string   "hashtag_prefix"
    t.string   "location"
    t.boolean  "open"
    t.string   "photo_content_type"
    t.string   "photo_file_name"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.decimal  "price"
    t.string   "recipient_api_account_ids"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "status"
    t.string   "id_hash"
    t.string   "closing_reason"
  end

  create_table "posts", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "hashtag_prefix"
    t.integer  "price",                     :limit => 8
    t.boolean  "open",                                   :default => true
    t.string   "location"
    t.string   "recipient_api_account_ids"
    t.string   "status",                                 :default => "ACT"
    t.string   "id_hash"
    t.string   "closing_reason"
  end

  add_index "posts", ["location"], :name => "index_posts_on_location"
  add_index "posts", ["updated_at"], :name => "index_posts_on_updated_at"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id_and_created_at"

  create_table "problem_reports", :force => true do |t|
    t.string   "exception_message"
    t.string   "exception_class"
    t.text     "exception_backtrace"
    t.string   "user_agent"
    t.string   "ip_address"
    t.string   "url_referrer"
    t.integer  "signed_in_user_id"
    t.string   "status",                  :default => "open"
    t.integer  "last_updated_by_user_id"
    t.integer  "owned_by_user_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "redirects", :force => true do |t|
    t.string   "key_code"
    t.string   "target_uri"
    t.integer  "clicks",     :default => 0
    t.boolean  "active",     :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "system_preferences", :force => true do |t|
    t.string   "preference_key"
    t.string   "preference_value"
    t.string   "constraints"
    t.string   "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "active",           :default => false
  end

  add_index "system_preferences", ["preference_key"], :name => "index_system_preferences_on_preference_key", :unique => true

  create_table "twitter_posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "api_account_id"
    t.integer  "post_id"
    t.string   "content"
    t.string   "twitter_post_id"
    t.string   "status",          :default => "new"
    t.string   "last_result",     :default => "no attempt"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "twitter_posts", ["api_account_id"], :name => "index_twitter_posts_on_api_account_id"
  add_index "twitter_posts", ["post_id"], :name => "index_twitter_posts_on_post_id"

  create_table "user_feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.text     "information"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_limitations", :force => true do |t|
    t.integer  "user_id"
    t.string   "limitation_type"
    t.integer  "user_limit"
    t.integer  "frequency"
    t.string   "frequency_type"
    t.boolean  "active",          :default => true
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "user_logins", :force => true do |t|
    t.integer  "user_id"
    t.string   "user_agent"
    t.string   "ip_address"
    t.string   "url_referrer"
    t.string   "login_source"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "session_json",    :limit => 500
    t.string   "paramaters_json", :limit => 500
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                     :default => false
    t.string   "status",                    :default => "UVR"
    t.string   "password_reset_code"
    t.string   "email_activation_code"
    t.string   "time_zone"
    t.string   "account_reactivation_code"
    t.string   "slug"
    t.string   "role",                      :default => "EXT"
    t.string   "photo_source"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

  create_table "violation_records", :force => true do |t|
    t.integer  "user_id"
    t.string   "violation"
    t.string   "violation_source"
    t.integer  "violation_source_id"
    t.string   "action_taken"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "watchedposts", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "watchedposts", ["created_at"], :name => "index_watchedposts_on_created_at"
  add_index "watchedposts", ["user_id", "post_id"], :name => "by_user_and_post", :unique => true

end
