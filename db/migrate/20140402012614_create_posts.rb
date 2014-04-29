class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to :recipe, index: true
      t.belongs_to :user, index: true
      t.string :title
      t.text :body
      t.integer :cached_votes_score, default: 0

      t.timestamps
    end

    add_index :posts, :cached_votes_score
  end
end
