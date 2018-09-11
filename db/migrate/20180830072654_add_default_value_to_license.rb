class AddDefaultValueToLicense < ActiveRecord::Migration[5.2]
  def change
    up_only do
      execute("UPDATE projects SET license = 3 WHERE license IS NULL")
    end

    change_column_null :projects, :license, false
  end
end
