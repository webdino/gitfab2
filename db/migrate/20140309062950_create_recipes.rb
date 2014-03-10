class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :type
      t.text :description
      t.string :photo
      t.string :youtube_url
      t.integer :owner_id, index: true

      t.timestamps
    end
  end
end
