class CreateProjectAccessStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :project_access_statistics do |t|
      t.date :date_on, null: false
      t.references :project, type: :integer, null: false, foreign_key: true
      t.integer :access_count, null: false, default: 0

      t.timestamps

      t.index %i[date_on project_id], unique: true
    end
  end
end
