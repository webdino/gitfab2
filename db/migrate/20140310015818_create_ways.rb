class CreateWays < ActiveRecord::Migration
  def change
    create_table :ways do |t|
      t.string :filename, index: true
      t.string :name
      t.string :photo
      t.string :video_id
      t.belongs_to :recipe, index: true
      t.belongs_to :status, index: true
      t.belongs_to :creator, index: true
      t.text :description
      t.integer :position, index: true
      t.string :reassoc_token
      t.integer :cached_votes_score, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :ways, :cached_votes_score
    add_index :ways, :deleted_at
  end
end
