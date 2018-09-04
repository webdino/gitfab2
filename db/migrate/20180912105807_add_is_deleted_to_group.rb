class AddIsDeletedToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :is_deleted, :boolean, null: false, default: false
  end
end
