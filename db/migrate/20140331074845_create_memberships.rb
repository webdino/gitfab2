class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to :user, index: true
      t.belongs_to :group, index: true
      t.string :role

      t.timestamps
    end
    add_index :memberships, [:user_id, :group_id], unique: true
  end
end
