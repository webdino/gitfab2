class AllowUsersEmailToNull < ActiveRecord::Migration[5.2]
  def up
    change_column_null :users, :email, true
    change_column_default :users, :email, nil
  end

  def down
    execute("UPDATE users SET email = '' WHERE email IS NULL")
    change_column_default :users, :email, ""
    change_column_null :users, :email, false
  end
end
