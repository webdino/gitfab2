class ChangeProjectConstraints < ActiveRecord::Migration[4.2]
  def change
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE projects SET is_deleted = false WHERE is_deleted IS NULL
    SQL
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE projects SET is_private = false WHERE is_private IS NULL
    SQL

    change_column_null :projects, :is_deleted, false
    change_column_null :projects, :is_private, false
  end
end
