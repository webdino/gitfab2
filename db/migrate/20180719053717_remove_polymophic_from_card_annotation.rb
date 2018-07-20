class RemovePolymophicFromCardAnnotation < ActiveRecord::Migration[4.2]
  def up
    remove_index :cards, name: :index_cards_annotatable
    remove_column :cards, :annotatable_type
    rename_column :cards, :annotatable_id, :annotation_id
    add_index :cards, :annotation_id
  end

  def down
    remove_index :cards, :annotation_id
    rename_column :cards, :annotation_id, :annotatable_id
    add_column :cards, :annotatable_type, :string
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE cards SET annotatable_type = 'Card'
      WHERE annotatable_id IS NOT NULL
    SQL
    add_index :cards, [:annotatable_type, :annotatable_id], name: :index_cards_annotatable
  end
end
