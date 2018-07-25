class MigrateIdentities < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      INSERT INTO identities (user_id, provider, uid, email, name, nickname, created_at, updated_at)
        SELECT id, provider, uid, email, fullname, name, created_at, updated_at FROM users
    SQL

    remove_column :users, :provider
    remove_column :users, :uid
  end

  def down
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    execute(<<~SQL)
      UPDATE users
      INNER JOIN identities ON users.id = identities.user_id
      SET
        users.provider = identities.provider,
        users.uid = identities.uid
    SQL

    execute("DELETE FROM identities")
  end
end
