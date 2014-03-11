class Material < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :status
  mount_uploader :photo, PhotoUploader
end
