class AddIndexPublished < ActiveRecord::Migration[5.1]
  def change
    add_index :projects, [:is_private, :is_deleted]
  end
end
