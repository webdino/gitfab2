class CreatePostAttachments < ActiveRecord::Migration
  def change
    create_table :post_attachments do |t|
      t.belongs_to :recipe, index: true
      t.string :content

      t.timestamps
    end
  end
end
