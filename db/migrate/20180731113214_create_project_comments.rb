class CreateProjectComments < ActiveRecord::Migration[5.2]
  def change
    create_table :project_comments, options: 'ROW_FORMAT=DYNAMIC' do |t|
      t.text :body, null: false
      t.references :user, foreign_key: true, type: :integer, null: false
      t.references :project, foreign_key: true, type: :integer, null: false

      t.timestamps
    end
  end
end
