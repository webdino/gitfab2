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

ActiveRecord::Schema.define(version: 20140414013837) do

  create_table "collaborations", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collaborations", ["recipe_id"], name: "index_collaborations_on_recipe_id", using: :btree
  add_index "collaborations", ["user_id"], name: "index_collaborations_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.string   "title",            limit: 50, default: ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.string   "role",                        default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contributor_recipes", force: true do |t|
    t.integer  "contributor_id"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "creator_id"
    t.string   "avatar"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["slug"], name: "index_groups_on_slug", unique: true, using: :btree

  create_table "materials", force: true do |t|
    t.string   "filename"
    t.string   "name"
    t.string   "url"
    t.string   "quantity"
    t.string   "photo"
    t.string   "size"
    t.text     "description"
    t.integer  "recipe_id"
    t.integer  "status_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "materials", ["recipe_id"], name: "index_materials_on_recipe_id", using: :btree
  add_index "materials", ["status_id"], name: "index_materials_on_status_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true, using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "post_attachments", force: true do |t|
    t.integer  "recipe_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_attachments", ["recipe_id"], name: "index_post_attachments_on_recipe_id", using: :btree

  create_table "posts", force: true do |t|
    t.integer  "recipe_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["recipe_id"], name: "index_posts_on_recipe_id", using: :btree

  create_table "recipes", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "type"
    t.text     "description"
    t.string   "photo"
    t.string   "youtube_url"
    t.integer  "user_id"
    t.integer  "last_committer_id"
    t.integer  "orig_recipe_id"
    t.integer  "group_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipes", ["group_id"], name: "index_recipes_on_group_id", using: :btree
  add_index "recipes", ["slug"], name: "index_recipes_on_slug", unique: true, using: :btree

  create_table "statuses", force: true do |t|
    t.string   "filename"
    t.integer  "position"
    t.text     "description"
    t.string   "photo"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["recipe_id"], name: "index_statuses_on_recipe_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tools", force: true do |t|
    t.string   "filename"
    t.string   "name"
    t.string   "url"
    t.string   "photo"
    t.text     "description"
    t.integer  "recipe_id"
    t.integer  "way_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tools", ["recipe_id"], name: "index_tools_on_recipe_id", using: :btree
  add_index "tools", ["way_id"], name: "index_tools_on_way_id", using: :btree

  create_table "usages", force: true do |t|
    t.integer  "recipe_id"
    t.string   "filename"
    t.integer  "position"
    t.text     "description"
    t.string   "photo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "usages", ["recipe_id"], name: "index_usages_on_recipe_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "avatar"
    t.integer  "group_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  create_table "way_sets", force: true do |t|
    t.integer  "recipe_id"
    t.integer  "status_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "way_sets", ["recipe_id"], name: "index_way_sets_on_recipe_id", using: :btree
  add_index "way_sets", ["status_id"], name: "index_way_sets_on_status_id", using: :btree

  create_table "ways", force: true do |t|
    t.string   "filename"
    t.string   "name"
    t.string   "photo"
    t.integer  "recipe_id"
    t.integer  "way_set_id"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ways", ["recipe_id"], name: "index_ways_on_recipe_id", using: :btree
  add_index "ways", ["way_set_id"], name: "index_ways_on_way_set_id", using: :btree

end
