class RemovePolymorphicFromContributions < ActiveRecord::Migration[4.2]
  def up
    remove_index :contributions, name: :index_contributions_contributable
    remove_column :contributions, :contributable_type
    rename_column :contributions, :contributable_id, :card_id
    add_foreign_key :contributions, :cards
  end

  def down
    remove_foreign_key :contributions, :cards
    rename_column :contributions, :card_id, :contributable_id
    add_column :contributions, :contributable_type, :string
    ActiveRecord::Base.connection.execute("UPDATE contributions SET contributable_type = 'Card'")
    change_column_null :contributions, :contributable_type, false
    add_index :contributions, [:contributable_type, :contributable_id], name: :index_contributions_contributable
  end
end
