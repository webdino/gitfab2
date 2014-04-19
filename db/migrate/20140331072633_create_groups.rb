class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :creator_id, index: true
      t.string :avatar
      t.string :slug

      t.timestamps
    end

    add_index :groups, :name, unique: true
    add_index :groups, :slug, unique: true
  end
end
