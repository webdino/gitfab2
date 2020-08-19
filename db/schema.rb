# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_19_134327) do

  create_table "attachments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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

  create_table "black_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", comment: "アクセスランキングブラックリスト", force: :cascade do |t|
    t.integer "project_id", null: false, comment: "ブラックリスト対象プロジェクト"
    t.integer "user_id", null: false, comment: "登録した管理者"
    t.text "reason", null: false, comment: "理由"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_black_lists_on_project_id"
    t.index ["user_id"], name: "index_black_lists_on_user_id"
  end

  create_table "card_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "card_id", null: false
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["card_id"], name: "fk_rails_c8dff2752a"
    t.index ["user_id"], name: "index_comments_user_id"
  end

  create_table "cards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.text "description", size: :long
    t.string "type", null: false
    t.integer "position", default: 0, null: false
    t.integer "project_id"
    t.integer "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "comments_count", default: 0, null: false
    t.index ["project_id"], name: "index_cards_project_id"
    t.index ["state_id"], name: "index_cards_on_state_id"
  end

  create_table "collaborations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "owner_type"
    t.integer "owner_id"
    t.integer "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_type", "owner_id"], name: "index_collaborations_owner"
    t.index ["project_id"], name: "index_collaborations_project_id"
  end

  create_table "contributions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "contributor_id", null: false
    t.integer "card_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["card_id"], name: "fk_rails_934cb2529a"
    t.index ["contributor_id"], name: "index_contributions_contributor_id"
  end

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "featured_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "feature_id"
    t.string "target_object_id"
    t.string "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["feature_id"], name: "index_featured_items_feature_id"
  end

  create_table "features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "class_name"
    t.string "name", null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "figures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "content"
    t.string "figurable_type"
    t.integer "figurable_id"
    t.string "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["figurable_type", "figurable_id"], name: "index_figures_figurable"
  end

  create_table "groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "avatar"
    t.string "slug"
    t.string "url"
    t.string "location"
    t.integer "projects_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false, null: false
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "identities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", comment: "認証情報", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.string "email"
    t.string "name"
    t.string "nickname"
    t.text "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "likes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id", "user_id"], name: "index_likes_unique", unique: true
    t.index ["project_id"], name: "index_likes_likable"
    t.index ["user_id"], name: "index_likes_liker_id"
  end

  create_table "memberships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.string "role", default: "editor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id", "user_id"], name: "index_users_on_group_id_user_id", unique: true
  end

  create_table "notifications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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

  create_table "project_access_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_access_logs_on_project_id"
    t.index ["user_id"], name: "index_project_access_logs_on_user_id"
  end

  create_table "project_access_statistics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.date "date_on", null: false
    t.integer "project_id", null: false
    t.integer "access_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date_on", "project_id"], name: "index_project_access_statistics_on_date_on_and_project_id", unique: true
    t.index ["project_id"], name: "index_project_access_statistics_on_project_id"
  end

  create_table "project_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.text "body", null: false
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_comments_on_project_id"
    t.index ["user_id"], name: "index_project_comments_on_user_id"
  end

  create_table "projects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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
    t.integer "license", null: false
    t.integer "original_id"
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "states_count", default: 0, null: false
    t.integer "usages_count", default: 0, null: false
    t.integer "note_cards_count", default: 0, null: false
    t.integer "project_access_logs_count", default: 0, null: false
    t.index ["is_private", "is_deleted"], name: "index_projects_on_is_private_and_is_deleted"
    t.index ["original_id"], name: "index_projects_original_id"
    t.index ["owner_type", "owner_id"], name: "index_projects_owner"
    t.index ["slug", "owner_type", "owner_id"], name: "index_projects_slug_owner", unique: true
    t.index ["updated_at"], name: "index_projects_updated_at"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], name: "fk_rails_2f90b9163e"
    t.index ["user_id"], name: "index_tags_user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "email", null: false
    t.string "slug"
    t.string "name"
    t.string "avatar"
    t.string "url"
    t.string "location"
    t.string "authority"
    t.integer "projects_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "password_digest"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "is_deleted", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "black_lists", "projects"
  add_foreign_key "black_lists", "users"
  add_foreign_key "card_comments", "cards"
  add_foreign_key "card_comments", "users", name: "fk_comments_user_id"
  add_foreign_key "cards", "projects", name: "fk_cards_project_id"
  add_foreign_key "contributions", "cards"
  add_foreign_key "contributions", "users", column: "contributor_id", name: "fk_contributions_contributor_id"
  add_foreign_key "featured_items", "features", name: "fk_featured_items_feature_id"
  add_foreign_key "identities", "users"
  add_foreign_key "likes", "users", name: "fk_likes_liker_id"
  add_foreign_key "notifications", "users", column: "notified_id", name: "fk_notifications_notified_id"
  add_foreign_key "notifications", "users", column: "notifier_id", name: "fk_notifications_notifier_id"
  add_foreign_key "project_access_logs", "projects"
  add_foreign_key "project_access_logs", "users"
  add_foreign_key "project_access_statistics", "projects"
  add_foreign_key "project_comments", "projects"
  add_foreign_key "project_comments", "users"
  add_foreign_key "tags", "projects"
  add_foreign_key "tags", "users", name: "fk_tags_user_id"
end
