class CreateContributorRecipes < ActiveRecord::Migration
  def change
    create_table :contributor_recipes do |t|
      t.integer :contributor_id
      t.integer :recipe_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :contributor_recipes, :deleted_at
  end
end
