class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :filename, index: true
      t.string :name
      t.string :url
      t.string :quantity
      t.string :photo
      t.string :size
      t.text :description
      t.belongs_to :recipe, index: true
      t.belongs_to :status, index: true
      t.integer :position, index: true

      t.timestamps
    end
  end
end
