class CreateContributorRecipes < ActiveRecord::Migration
  def change
    create_table :contributor_recipes do |t|
      t.integer :contributor_id
      t.integer :recipe_id

      t.timestamps
    end
  end
end
