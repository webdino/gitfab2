class RemovePolymorphicFromTags < ActiveRecord::Migration[4.2]
  def up
    remove_index :tags, name: :index_tags_taggable
    remove_column :tags, :taggable_type
    rename_column :tags, :taggable_id, :project_id
    add_foreign_key :tags, :projects
  end

  def down
    remove_foreign_key :tags, :projects
    rename_column :tags, :project_id, :taggable_id
    add_column :tags, :taggable_type, :string
    execute("UPDATE tags SET taggable_type = 'Project'")
    add_index :tags, [:taggable_type, :taggable_id], name: :index_tags_taggable
  end
end
