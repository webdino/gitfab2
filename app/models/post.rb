class Post < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :recipe_id, :title, :body]

  belongs_to :recipe
  has_many :post_attachments

  accepts_nested_attributes_for :post_attachments, allow_destroy: true
end
