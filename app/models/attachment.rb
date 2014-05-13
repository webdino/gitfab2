class Attachment < ActiveRecord::Base
  mount_uploader :content, AttachmentUploader
  
  belongs_to :recipe
end
