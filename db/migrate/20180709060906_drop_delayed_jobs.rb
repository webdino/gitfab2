class DropDelayedJobs < ActiveRecord::Migration[4.2]
  def up
    drop_table :delayed_jobs
  end

  def down
    create_table "delayed_jobs", force: :cascade do |t|
      t.integer  "priority",   limit: 4,     default: 0, null: false
      t.integer  "attempts",   limit: 4,     default: 0, null: false
      t.text     "handler",    limit: 65535,             null: false
      t.text     "last_error", limit: 65535
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by",  limit: 255
      t.string   "queue",      limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end
end
