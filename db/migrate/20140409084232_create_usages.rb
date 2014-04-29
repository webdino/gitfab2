class CreateUsages < ActiveRecord::Migration
  def change
    create_table :usages do |t|
      t.belongs_to :recipe, index: true
      t.string :filename, index: true
      t.integer :position, index: true
      t.string :title
      t.text :description
      t.string :photo
      t.integer :cached_votes_score, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :usages, :cached_votes_score
    add_index :usages, :deleted_at
  end
end
