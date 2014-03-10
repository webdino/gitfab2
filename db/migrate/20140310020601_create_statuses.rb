class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.integer :prev_id
      t.belongs_to :recipe

      t.timestamps
    end
  end
end
