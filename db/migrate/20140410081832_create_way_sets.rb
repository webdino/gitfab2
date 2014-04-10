class CreateWaySets < ActiveRecord::Migration
  def change
    create_table :way_sets do |t|
      t.belongs_to :recipe, index: true
      t.integer :position, index: true

      t.timestamps
    end
  end
end
