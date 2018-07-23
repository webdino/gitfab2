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

ActiveRecord::Schema.define(version: 20180723031303) do

  create_table "attachments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "content"
    t.string "attachable_type", null: false
    t.integer "attachable_id", null: false
    t.string "markup_id"
    t.text "link"
    t.text "title"
    t.string "description"
    t.string "kind"
    t.string "content_tmp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_attachable"
  end

  create_table "cards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "title"
    t.text "description", limit: 4294967295
    t.string "type", null: false
    t.integer "position", default: 0, null: false
    t.integer "recipe_id"
    t.integer "project_id"
    t.integer "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_cards_project_id"
    t.index ["recipe_id"], name: "index_cards_recipe_id"
    t.index ["state_id"], name: "index_cards_on_state_id"
  end

  create_table "collaborations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "owner_type"
    t.integer "owner_id"
    t.integer "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_type", "owner_id"], name: "index_collaborations_owner"
    t.index ["project_id"], name: "index_collaborations_project_id"
  end

  create_table "comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "user_id", null: false
    t.integer "card_id", null: false
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["card_id"], name: "fk_rails_c8dff2752a"
    t.index ["user_id"], name: "index_comments_user_id"
  end

  create_table "contributions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "contributor_id", null: false
    t.integer "card_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["card_id"], name: "fk_rails_934cb2529a"
    t.index ["contributor_id"], name: "index_contributions_contributor_id"
  end

  create_table "featured_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "feature_id"
    t.string "target_object_id"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["feature_id"], name: "index_featured_items_feature_id"
  end

  create_table "features", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "class_name"
    t.string "name", null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "figures", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "content"
    t.string "figurable_type"
    t.integer "figurable_id"
    t.string "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["figurable_type", "figurable_id"], name: "index_figures_figurable"
  end

  create_table "groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "name"
    t.string "avatar"
    t.string "slug"
    t.string "url"
    t.string "location"
    t.integer "projects_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "likes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id", "user_id"], name: "index_likes_unique", unique: true
    t.index ["project_id"], name: "index_likes_likable"
    t.index ["user_id"], name: "index_likes_liker_id"
  end

  create_table "memberships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.string "role", default: "editor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id", "user_id"], name: "index_users_on_group_id_user_id", unique: true
  end

  create_table "notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "notifier_id"
    t.integer "notified_id"
    t.string "notificatable_url"
    t.string "notificatable_type"
    t.string "body"
    t.boolean "was_read", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notified_id"], name: "index_notifications_on_notified_id"
    t.index ["notifier_id"], name: "index_notifications_on_notifier_id"
  end

  create_table "projects", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "name", null: false
    t.string "title", null: false
    t.text "description"
    t.text "draft"
    t.boolean "is_private", default: false, null: false
    t.boolean "is_deleted", default: false, null: false
    t.string "owner_type", null: false
    t.integer "owner_id", null: false
    t.string "slug"
    t.string "scope"
    t.integer "license"
    t.integer "original_id"
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["original_id"], name: "index_projects_original_id"
    t.index ["owner_type", "owner_id"], name: "index_projects_owner"
    t.index ["slug", "owner_type", "owner_id"], name: "index_projects_slug_owner", unique: true
    t.index ["updated_at"], name: "index_projects_updated_at"
  end

  create_table "recipes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "index_recipes_project_id"
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "fk_rails_2f90b9163e"
    t.index ["user_id"], name: "index_tags_user_id"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string "email", default: "", null: false
    t.string "provider"
    t.string "uid"
    t.string "slug"
    t.string "name"
    t.string "fullname"
    t.string "avatar"
    t.string "url"
    t.string "location"
    t.string "authority"
    t.integer "projects_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "cards", "projects", name: "fk_cards_project_id"
  add_foreign_key "cards", "recipes", name: "fk_cards_recipe_id"
  add_foreign_key "comments", "cards"
  add_foreign_key "comments", "users", name: "fk_comments_user_id"
  add_foreign_key "contributions", "cards"
  add_foreign_key "contributions", "users", column: "contributor_id", name: "fk_contributions_contributor_id"
  add_foreign_key "featured_items", "features", name: "fk_featured_items_feature_id"
  add_foreign_key "likes", "users", name: "fk_likes_liker_id"
  add_foreign_key "notifications", "users", column: "notified_id", name: "fk_notifications_notified_id"
  add_foreign_key "notifications", "users", column: "notifier_id", name: "fk_notifications_notifier_id"
  add_foreign_key "recipes", "projects", name: "fk_recipes_project_id"
  add_foreign_key "tags", "projects"
  add_foreign_key "tags", "users", name: "fk_tags_user_id"
end
