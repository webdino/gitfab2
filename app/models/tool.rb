class Tool < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :way
  mount_uploader :photo, PhotoUploader
end
