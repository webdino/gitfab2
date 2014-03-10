class CreateWays < ActiveRecord::Migration
  def change
    create_table :ways do |t|
      t.string :name
      t.string :photo
      t.integer :prev_status_id, index: true
      t.integer :next_status_id, index: true
      t.belongs_to :recipe, index: true
      t.text :description

      t.timestamps
    end
  end
end
