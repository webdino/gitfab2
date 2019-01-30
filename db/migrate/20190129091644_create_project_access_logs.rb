class CreateProjectAccessLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :project_access_logs do |t|
      t.references :project, foreign_key: true, null: false, type: :integer
      t.references :user, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
