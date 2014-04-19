class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :title
      t.string :type
      t.text :description
      t.string :photo
      t.string :youtube_url
      t.belongs_to :owner, polymorphic: true
      t.integer :last_committer_id, index: true
      t.integer :orig_recipe_id, index: true
      t.string :slug

      t.timestamps
    end

    add_index :recipes, :owner_type
    add_index :recipes, :owner_id
    add_index :recipes, [:owner_id, :owner_type, :slug], unique: true
  end
end
