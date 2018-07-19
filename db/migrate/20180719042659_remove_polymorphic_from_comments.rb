class RemovePolymorphicFromComments < ActiveRecord::Migration
  def up
    remove_index :comments, name: :index_comments_commentable
    remove_column :comments, :commentable_type
    rename_column :comments, :commentable_id, :card_id
    add_foreign_key :comments, :cards
  end

  def down
    remove_foreign_key :comments, :cards
    rename_column :comments, :card_id, :commentable_id
    add_column :comments, :commentable_type, :string
    ActiveRecord::Base.connection.execute("UPDATE comments SET commentable_type = 'Card'")
    change_column_null :comments, :commentable_type, false
    add_index :comments, [:commentable_type, :commentable_id], name: :index_comments_commentable
  end
end
