class PostAttachment < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :content, :_destroy]

  mount_uploader :content, PhotoUploader

  belongs_to :post
end
