class DropColumnLikesCount < ActiveRecord::Migration[4.2]
  def change
    remove_column :cards, :likes_count, :integer, null: false, default: 0
    remove_column :comments, :likes_count, :integer, null: false, default: 0
  end
end
