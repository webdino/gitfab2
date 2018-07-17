class RemoveColumnOldid < ActiveRecord::Migration[4.2]
  def change
    remove_column :attachments, :oldid, :string
    remove_column :cards, :oldid, :string
    remove_column :collaborations, :oldid, :string
    remove_column :comments, :oldid, :string
    remove_column :contributions, :oldid, :string
    remove_column :featured_items, :oldid, :string
    remove_column :features, :oldid, :string
    remove_column :figures, :oldid, :string
    remove_column :groups, :oldid, :string
    remove_column :likes, :oldid, :string
    remove_column :memberships, :oldid, :string
    remove_column :notes, :oldid, :string
    remove_column :notifications, :oldid, :string
    remove_column :projects, :oldid, :string
    remove_column :recipes, :oldid, :string
    remove_column :tags, :oldid, :string
    remove_column :users, :oldid, :string
  end
end
