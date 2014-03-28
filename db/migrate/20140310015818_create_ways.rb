class CreateWays < ActiveRecord::Migration
  def change
    create_table :ways do |t|
      t.string :filename, index: true
      t.string :name
      t.string :photo
      t.belongs_to :recipe, index: true
      t.integer :number, index: true
      t.text :description
      t.integer :position, index: true

      t.timestamps
    end
  end
end
