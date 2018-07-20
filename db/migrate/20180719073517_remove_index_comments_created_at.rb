class RemoveIndexCommentsCreatedAt < ActiveRecord::Migration[4.2]
  def change
    remove_index :comments, column: :created_at, name: :index_comments_created_at
  end
end
