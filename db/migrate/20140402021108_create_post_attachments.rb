class CreatePostAttachments < ActiveRecord::Migration
  def change
    create_table :post_attachments do |t|
      t.belongs_to :recipe, index: true
      t.string :content
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :post_attachments, :deleted_at
  end
end
