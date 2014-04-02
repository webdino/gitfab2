class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to :recipe, index: true
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
