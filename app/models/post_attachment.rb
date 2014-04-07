class PostAttachment < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :content, :_destroy]

  mount_uploader :content, PostAttachmentUploader

  belongs_to :recipe
end
