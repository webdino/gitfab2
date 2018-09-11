class RenameCommentsToCardCommnets < ActiveRecord::Migration[5.2]
  def change
    rename_table :comments, :card_comments
  end
end
