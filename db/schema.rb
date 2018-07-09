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

ActiveRecord::Schema.define(version: 20180709060906) do

  create_table "attachments", force: :cascade do |t|
    t.string   "content",         limit: 255
    t.string   "attachable_type", limit: 255,   null: false
    t.integer  "attachable_id",   limit: 4,     null: false
    t.string   "markup_id",       limit: 255
    t.text     "link",            limit: 65535
    t.text     "title",           limit: 65535
    t.string   "description",     limit: 255
    t.string   "kind",            limit: 255
    t.string   "content_tmp",     limit: 255
    t.string   "oldid",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["attachable_type", "attachable_id"], name: "index_attachments_attachable", using: :btree

  create_table "cards", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.text     "description",      limit: 4294967295
    t.string   "type",             limit: 255,                    null: false
    t.integer  "likes_count",      limit: 4,          default: 0, null: false
    t.integer  "position",         limit: 4,          default: 0, null: false
    t.integer  "recipe_id",        limit: 4
    t.integer  "note_id",          limit: 4
    t.integer  "project_id",       limit: 4
    t.string   "annotatable_type", limit: 255
    t.integer  "annotatable_id",   limit: 4
    t.string   "oldid",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cards", ["annotatable_type", "annotatable_id"], name: "index_cards_annotatable", using: :btree
  add_index "cards", ["note_id"], name: "index_cards_note_id", using: :btree
  add_index "cards", ["project_id"], name: "index_cards_project_id", using: :btree
  add_index "cards", ["recipe_id"], name: "index_cards_recipe_id", using: :btree

  create_table "collaborations", force: :cascade do |t|
    t.string   "owner_type", limit: 255
    t.integer  "owner_id",   limit: 4
    t.integer  "project_id", limit: 4,   null: false
    t.string   "oldid",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collaborations", ["owner_type", "owner_id"], name: "index_collaborations_owner", using: :btree
  add_index "collaborations", ["project_id"], name: "index_collaborations_project_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",          limit: 4,                 null: false
    t.integer  "commentable_id",   limit: 4,                 null: false
    t.string   "commentable_type", limit: 255,               null: false
    t.text     "body",             limit: 65535
    t.integer  "likes_count",      limit: 4,     default: 0, null: false
    t.string   "oldid",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_commentable", using: :btree
  add_index "comments", ["created_at"], name: "index_comments_created_at", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_user_id", using: :btree

  create_table "contributions", force: :cascade do |t|
    t.integer  "contributor_id",     limit: 4,   null: false
    t.integer  "contributable_id",   limit: 4,   null: false
    t.string   "contributable_type", limit: 255, null: false
    t.string   "oldid",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contributions", ["contributable_type", "contributable_id"], name: "index_contributions_contributable", using: :btree
  add_index "contributions", ["contributor_id"], name: "index_contributions_contributor_id", using: :btree

  create_table "featured_items", force: :cascade do |t|
    t.integer  "feature_id",       limit: 4
    t.string   "target_object_id", limit: 255
    t.string   "url",              limit: 255
    t.string   "oldid",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_items", ["feature_id"], name: "index_featured_items_feature_id", using: :btree

  create_table "features", force: :cascade do |t|
    t.string   "class_name", limit: 255
    t.string   "name",       limit: 255,             null: false
    t.integer  "category",   limit: 4,   default: 0, null: false
    t.string   "oldid",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "figures", force: :cascade do |t|
    t.string   "content",        limit: 255
    t.string   "figurable_type", limit: 255
    t.integer  "figurable_id",   limit: 4
    t.string   "link",           limit: 255
    t.string   "oldid",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "figures", ["figurable_type", "figurable_id"], name: "index_figures_figurable", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "avatar",         limit: 255
    t.string   "slug",           limit: 255
    t.string   "url",            limit: 255
    t.string   "location",       limit: 255
    t.integer  "projects_count", limit: 4,   default: 0, null: false
    t.string   "oldid",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "groups", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  create_table "likes", force: :cascade do |t|
    t.integer  "liker_id",     limit: 4,   null: false
    t.string   "likable_type", limit: 255, null: false
    t.integer  "likable_id",   limit: 4,   null: false
    t.string   "oldid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "likes", ["likable_type", "likable_id", "liker_id"], name: "index_likes_unique", unique: true, using: :btree
  add_index "likes", ["likable_type", "likable_id"], name: "index_likes_likable", using: :btree
  add_index "likes", ["liker_id"], name: "index_likes_liker_id", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "role",       limit: 255, default: "editor"
    t.string   "oldid",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["group_id", "user_id"], name: "index_users_on_group_id_user_id", unique: true, using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.integer  "num_cards",  limit: 4,   default: 0, null: false
    t.string   "oldid",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["num_cards"], name: "index_notes_num_cards", using: :btree
  add_index "notes", ["project_id"], name: "index_notes_project_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "notifier_id",        limit: 4
    t.integer  "notified_id",        limit: 4
    t.string   "notificatable_url",  limit: 255
    t.string   "notificatable_type", limit: 255
    t.string   "body",               limit: 255
    t.boolean  "was_read",                       default: false
    t.string   "oldid",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["notified_id"], name: "index_notifications_on_notified_id", using: :btree
  add_index "notifications", ["notifier_id"], name: "index_notifications_on_notifier_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",        limit: 255,                   null: false
    t.string   "title",       limit: 255,                   null: false
    t.text     "description", limit: 65535
    t.text     "draft",       limit: 65535
    t.boolean  "is_private",                default: false
    t.boolean  "is_deleted",                default: false
    t.string   "owner_type",  limit: 255,                   null: false
    t.integer  "owner_id",    limit: 4,                     null: false
    t.string   "slug",        limit: 255
    t.string   "scope",       limit: 255
    t.integer  "license",     limit: 4
    t.integer  "original_id", limit: 4
    t.integer  "likes_count", limit: 4,     default: 0,     null: false
    t.string   "oldid",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["likes_count"], name: "index_projects_on_likes_count", using: :btree
  add_index "projects", ["original_id"], name: "index_projects_original_id", using: :btree
  add_index "projects", ["owner_type", "owner_id"], name: "index_projects_owner", using: :btree
  add_index "projects", ["slug", "owner_type", "owner_id"], name: "index_projects_slug_owner", unique: true, using: :btree
  add_index "projects", ["updated_at"], name: "index_projects_updated_at", using: :btree

  create_table "recipes", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.string   "oldid",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipes", ["project_id"], name: "index_recipes_project_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "taggable_id",   limit: 4
    t.string   "name",          limit: 255
    t.string   "oldid",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["taggable_type", "taggable_id"], name: "index_tags_taggable", using: :btree
  add_index "tags", ["user_id"], name: "index_tags_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",               limit: 255, default: "", null: false
    t.string   "encrypted_password",  limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",  limit: 255
    t.string   "last_sign_in_ip",     limit: 255
    t.string   "provider",            limit: 255
    t.string   "uid",                 limit: 255
    t.string   "slug",                limit: 255
    t.string   "name",                limit: 255
    t.string   "fullname",            limit: 255
    t.string   "avatar",              limit: 255
    t.string   "url",                 limit: 255
    t.string   "location",            limit: 255
    t.string   "authority",           limit: 255
    t.integer  "projects_count",      limit: 4,   default: 0,  null: false
    t.string   "oldid",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  add_foreign_key "cards", "notes", name: "fk_cards_note_id"
  add_foreign_key "cards", "projects", name: "fk_cards_project_id"
  add_foreign_key "cards", "recipes", name: "fk_cards_recipe_id"
  add_foreign_key "comments", "users", name: "fk_comments_user_id"
  add_foreign_key "contributions", "users", column: "contributor_id", name: "fk_contributions_contributor_id"
  add_foreign_key "featured_items", "features", name: "fk_featured_items_feature_id"
  add_foreign_key "likes", "users", column: "liker_id", name: "fk_likes_liker_id"
  add_foreign_key "notes", "projects", name: "fk_notes_project_id"
  add_foreign_key "notifications", "users", column: "notified_id", name: "fk_notifications_notified_id"
  add_foreign_key "notifications", "users", column: "notifier_id", name: "fk_notifications_notifier_id"
  add_foreign_key "recipes", "projects", name: "fk_recipes_project_id"
  add_foreign_key "tags", "users", name: "fk_tags_user_id"
end
