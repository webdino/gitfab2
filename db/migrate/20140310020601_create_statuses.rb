class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :filename, index: true
      t.integer :position, index: true
      t.text :description
      t.string :photo
      t.belongs_to :recipe, index: true
      t.string :reassoc_token

      t.timestamps
    end
  end
end
