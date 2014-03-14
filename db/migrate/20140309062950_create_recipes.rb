class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :repo_path
      t.string :title
      t.string :type
      t.text :description
      t.string :photo
      t.string :youtube_url
      t.integer :user_id, index: true
      t.integer :last_committer_id, index: true
      t.integer :orig_recipe_id, index: true

      t.timestamps
    end
  end
end
