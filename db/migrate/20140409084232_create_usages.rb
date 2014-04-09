class CreateUsages < ActiveRecord::Migration
  def change
    create_table :usages do |t|
      t.belongs_to :recipe, index: true
      t.string :filename, index: true
      t.integer :position, index: true
      t.text :description
      t.string :photo

      t.timestamps
    end
  end
end
