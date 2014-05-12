class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :filename, index: true
      t.integer :position, index: true
      t.text :description
      t.string :photo
      t.string :video_id
      t.belongs_to :recipe, index: true
      t.string :reassoc_token
      t.integer :cached_votes_score, default: 0
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :statuses, :cached_votes_score
    add_index :statuses, :deleted_at
  end
end
