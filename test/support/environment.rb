require 'active_record'
require 'sqlite3'
require 'rails'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do

  create_table "accounts", force: true do |t|
    t.string   "user_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "username"
    t.integer  "star"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "users", force: true do |t|
    t.integer  "account_id"
    t.string   "account_email"
    t.integer  "posts_count"
    t.integer  "posts_star"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

autoload :Account, 'support/models/account'
autoload :Post, 'support/models/post'
autoload :User, 'support/models/user'
