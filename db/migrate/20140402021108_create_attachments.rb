class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.belongs_to :recipe, index: true
      t.string :content
      t.string :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :attachments, :deleted_at
  end
end
