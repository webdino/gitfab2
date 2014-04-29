class CreateCollaborations < ActiveRecord::Migration
  def change
    create_table :collaborations do |t|
      t.belongs_to :user, index: true
      t.belongs_to :recipe, index: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :collaborations, :deleted_at
  end
end
