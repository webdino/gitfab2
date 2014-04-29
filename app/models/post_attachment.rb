class PostAttachment < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :content, :_destroy]

  mount_uploader :content, PostAttachmentUploader

  acts_as_paranoid

  belongs_to :recipe
end
