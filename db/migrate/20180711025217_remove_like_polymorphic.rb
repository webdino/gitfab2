class RemoveLikePolymorphic < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.connection.execute("DELETE FROM likes WHERE likable_type <> 'Project'")
    remove_column :likes, :likable_type
    rename_column :likes, :likable_id, :project_id
    rename_column :likes, :liker_id, :user_id
  end

  def down
    add_column :likes, :likable_type, :string
    rename_column :likes, :project_id, :likable_id
    rename_column :likes, :user_id, :liker_id
  end
end
