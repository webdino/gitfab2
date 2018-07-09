class DropDeviseColumnFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, "encrypted_password", :string, limit: 255
    remove_column :users, "remember_created_at", :datetime
    remove_column :users, "sign_in_count", :integer, limit: 4, default: 0, null: false
    remove_column :users, "current_sign_in_at", :datetime
    remove_column :users, "last_sign_in_at", :datetime
    remove_column :users, "current_sign_in_ip", :string, limit: 255
    remove_column :users, "last_sign_in_ip", :string, limit: 255
  end
end
