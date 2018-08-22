class DropTableRecipes < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      UPDATE cards
      INNER JOIN recipes ON cards.recipe_id = recipes.id
      SET cards.project_id = recipes.project_id
    SQL

    remove_reference :cards, :recipe
    drop_table :recipes
  end

  def down
    create_table "recipes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
      t.integer "project_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["project_id"], name: "index_recipes_project_id"
    end

    add_reference :cards, :recipe, index: true
  end
end
