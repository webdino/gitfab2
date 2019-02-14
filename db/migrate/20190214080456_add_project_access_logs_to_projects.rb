class AddProjectAccessLogsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :project_access_logs_count, :integer, default: 0, null: false

    up_only do
      execute(<<~SQL)
        UPDATE projects
        INNER JOIN (
          SELECT project_id, COUNT(id) project_access_logs_count
          FROM project_access_logs
          GROUP BY project_id
        ) t
        ON projects.id = t.project_id
        SET projects.project_access_logs_count = t.project_access_logs_count
      SQL
    end
  end
end
