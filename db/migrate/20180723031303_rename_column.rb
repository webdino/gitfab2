class RenameColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :cards, :annotation_id, :state_id
  end
end
