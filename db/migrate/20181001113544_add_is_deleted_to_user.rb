class AddIsDeletedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_deleted, :boolean, null: false, default: false
  end
end
