class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :filename, index: true
      t.string :name
      t.string :url
      t.string :photo
      t.text :description
      t.belongs_to :recipe, index: true
      t.belongs_to :way, index: true
      t.integer :position, index: true

      t.timestamps
    end
  end
end
