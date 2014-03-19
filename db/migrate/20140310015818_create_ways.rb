class CreateWays < ActiveRecord::Migration
  def change
    create_table :ways do |t|
      t.string :uuid, index: true
      t.string :name
      t.string :photo
      t.belongs_to :status, index: true
      t.belongs_to :recipe, index: true
      t.text :description
      t.integer :position, index: true

      t.timestamps
    end
  end
end
